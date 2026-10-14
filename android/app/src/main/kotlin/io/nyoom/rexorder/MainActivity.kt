package io.nyoom.rexorder

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.os.storage.StorageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val modelExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var modelProgressSink: EventChannel.EventSink? = null
    private var chargingEventSink: EventChannel.EventSink? = null
    private var chargingReceiverRegistered = false
    private var lastChargingState: Boolean? = null
    private var pendingPickerResult: MethodChannel.Result? = null
    private lateinit var modelImporter: ModelImporter
    private val chargingReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            publishCharging(currentChargingState())
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        modelImporter = ModelImporter(contentResolver, cacheDir, filesDir)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rexorder/storage",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "listVolumes" -> {
                    try {
                        val storageManager = getSystemService(
                            Context.STORAGE_SERVICE,
                        ) as StorageManager
                        val volumes = getExternalFilesDirs(null)
                            .filterNotNull()
                            .map { file ->
                                val storageVolume = storageManager.getStorageVolume(file)
                                mapOf(
                                    "path" to file.absolutePath,
                                    "removable" to (storageVolume?.isRemovable ?: false),
                                    "mounted" to (
                                        Environment.getExternalStorageState(file) ==
                                            Environment.MEDIA_MOUNTED
                                        ),
                                    "description" to (
                                        storageVolume?.getDescription(this)
                                            ?: file.absolutePath
                                        ),
                                    "freeBytes" to file.usableSpace,
                                    "totalBytes" to file.totalSpace,
                                )
                            }
                        result.success(volumes)
                    } catch (error: Exception) {
                        result.error(
                            "storage_discovery_failed",
                            error.message ?: "Unable to list storage volumes.",
                            null,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rexorder/recording_service",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val intent = Intent(this, RecordingService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "stop" -> {
                    stopService(Intent(this, RecordingService::class.java))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rexorder/power",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isCharging" -> result.success(currentChargingState())
                else -> result.notImplemented()
            }
        }
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rexorder/power/charging",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                chargingEventSink = events
                lastChargingState = null
                val filter = IntentFilter().apply {
                    addAction(Intent.ACTION_POWER_CONNECTED)
                    addAction(Intent.ACTION_POWER_DISCONNECTED)
                    addAction(Intent.ACTION_BATTERY_CHANGED)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    registerReceiver(
                        chargingReceiver,
                        filter,
                        Context.RECEIVER_NOT_EXPORTED,
                    )
                } else {
                    registerReceiver(chargingReceiver, filter)
                }
                chargingReceiverRegistered = true
                publishCharging(currentChargingState())
            }

            override fun onCancel(arguments: Any?) {
                chargingEventSink = null
                lastChargingState = null
                if (chargingReceiverRegistered) {
                    unregisterReceiver(chargingReceiver)
                    chargingReceiverRegistered = false
                }
            }
        })

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rexorder/models",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDocument" -> pickDocument(result)
                "importModel" -> {
                    val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
                    val modelId = call.argument<String>("modelId")
                    val displayName = call.argument<String>("displayName")
                    val kind = call.argument<String>("kind")
                    val files = call.argument<List<String>>("files")
                    val targetFileName = call.argument<String>("targetFileName")
                    if (
                        uri == null || modelId == null || displayName == null ||
                        kind == null || files == null
                    ) {
                        result.error("invalid_arguments", "Missing model import arguments.", null)
                    } else {
                        modelExecutor.execute {
                            try {
                                val directory = modelImporter.importModel(
                                    uri,
                                    modelId,
                                    displayName,
                                    files,
                                    kind,
                                    targetFileName,
                                ) { stage, bytesRead, totalBytes ->
                                    mainHandler.post {
                                        modelProgressSink?.success(
                                            mapOf(
                                                "modelId" to modelId,
                                                "stage" to stage,
                                                "bytesRead" to bytesRead,
                                                "totalBytes" to totalBytes,
                                            ),
                                        )
                                    }
                                }
                                mainHandler.post { result.success(directory) }
                            } catch (error: Exception) {
                                mainHandler.post {
                                    result.error(
                                        "model_import_failed",
                                        error.message ?: "Model import failed.",
                                        null,
                                    )
                                }
                            }
                        }
                    }
                }
                "listInstalled" -> {
                    modelExecutor.execute {
                        val installed = modelImporter.listInstalled()
                        mainHandler.post { result.success(installed) }
                    }
                }
                "delete" -> {
                    val modelId = call.argument<String>("modelId")
                    if (modelId == null) {
                        result.error("invalid_arguments", "Missing model id.", null)
                    } else {
                        modelExecutor.execute {
                            val deleted = modelImporter.delete(modelId)
                            mainHandler.post { result.success(deleted) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rexorder/models/progress",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                modelProgressSink = events
            }

            override fun onCancel(arguments: Any?) {
                modelProgressSink = null
            }
        })
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rexorder/processing_service",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    try {
                        val intent = Intent(this, ProcessingService::class.java)
                            .putExtra(
                                ProcessingService.EXTRA_TITLE,
                                call.argument<String>("title"),
                            )
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    } catch (error: Exception) {
                        result.error(
                            "fgs_start_failed",
                            error.message ?: "Unable to start transcription service.",
                            null,
                        )
                    }
                }
                "update" -> {
                    try {
                        ProcessingService.notifyProgress(
                            this,
                            call.argument<String>("title") ?: "Transcribing",
                            call.argument<Int>("progress") ?: 0,
                            call.argument<Int>("max") ?: 0,
                            call.argument<String>("stage") ?: "transcribing",
                        )
                        result.success(null)
                    } catch (error: Exception) {
                        result.error(
                            "notification_update_failed",
                            error.message ?: "Unable to update transcription notification.",
                            null,
                        )
                    }
                }
                "stop" -> {
                    stopService(Intent(this, ProcessingService::class.java))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun pickDocument(result: MethodChannel.Result) {
        if (pendingPickerResult != null) {
            result.error("picker_busy", "A document picker is already open.", null)
            return
        }
        pendingPickerResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivityForResult(intent, MODEL_PICKER_REQUEST)
    }

    private fun currentChargingState(): Boolean {
        val batteryIntent = registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED),
        ) ?: return false
        val status = batteryIntent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        val plugged = batteryIntent.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0)
        return status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL ||
            plugged != 0
    }

    private fun publishCharging(charging: Boolean) {
        if (lastChargingState == charging) return
        lastChargingState = charging
        chargingEventSink?.success(charging)
    }

    @Deprecated("Deprecated by Android, retained for FlutterActivity compatibility.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == MODEL_PICKER_REQUEST) {
            val uri = if (resultCode == Activity.RESULT_OK) data?.data?.toString() else null
            pendingPickerResult?.success(uri)
            pendingPickerResult = null
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        if (chargingReceiverRegistered) {
            unregisterReceiver(chargingReceiver)
            chargingReceiverRegistered = false
        }
        modelExecutor.shutdown()
        super.onDestroy()
    }

    companion object {
        private const val MODEL_PICKER_REQUEST = 771
    }
}
