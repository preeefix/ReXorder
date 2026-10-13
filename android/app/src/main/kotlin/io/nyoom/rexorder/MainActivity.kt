package io.nyoom.rexorder

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val modelExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var modelProgressSink: EventChannel.EventSink? = null
    private var pendingPickerResult: MethodChannel.Result? = null
    private lateinit var modelImporter: ModelImporter

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        modelImporter = ModelImporter(contentResolver, cacheDir, filesDir)
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
            "rexorder/models",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDocument" -> pickDocument(result)
                "importModel" -> {
                    val uri = call.argument<String>("uri")?.let { Uri.parse(it) }
                    val modelId = call.argument<String>("modelId")
                    val sha256 = call.argument<String>("sha256")
                    val kind = call.argument<String>("kind")
                    if (uri == null || modelId == null || sha256 == null || kind == null) {
                        result.error("invalid_arguments", "Missing model import arguments.", null)
                    } else {
                        modelExecutor.execute {
                            try {
                                val directory = modelImporter.importModel(
                                    uri,
                                    modelId,
                                    sha256,
                                    kind,
                                ) { bytesRead, totalBytes ->
                                    mainHandler.post {
                                        modelProgressSink?.success(
                                            mapOf(
                                                "modelId" to modelId,
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
        modelExecutor.shutdown()
        super.onDestroy()
    }

    companion object {
        private const val MODEL_PICKER_REQUEST = 771
    }
}
