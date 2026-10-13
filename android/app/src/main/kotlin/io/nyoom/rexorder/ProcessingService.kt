package io.nyoom.rexorder

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

class ProcessingService : Service() {
    private var title = "Transcribing"
    private var progress = 0
    private var max = 0
    private var stage = STAGE_TRANSCRIBING

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.getStringExtra(EXTRA_TITLE)?.let { title = it }
        intent?.getStringExtra(EXTRA_STAGE)?.let { stage = it }
        if (intent?.hasExtra(EXTRA_PROGRESS) == true) {
            progress = intent.getIntExtra(EXTRA_PROGRESS, progress)
            max = intent.getIntExtra(EXTRA_MAX, max)
        }
        val notification = buildNotification(this, title, progress, max, stage)
        if (Build.VERSION.SDK_INT >= 35) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROCESSING,
            )
        } else if (Build.VERSION.SDK_INT >= 29) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val EXTRA_TITLE = "title"
        const val EXTRA_PROGRESS = "progress"
        const val EXTRA_MAX = "max"
        const val EXTRA_STAGE = "stage"
        const val STAGE_SPEAKERS = "speakers"
        const val STAGE_TRANSCRIBING = "transcribing"
        private const val CHANNEL_ID = "rexorder_processing"
        private const val NOTIFICATION_ID = 702

        fun notifyProgress(
            context: Context,
            title: String,
            progress: Int,
            max: Int,
            stage: String,
        ) {
            createNotificationChannel(context)
            val notification = buildNotification(context, title, progress, max, stage)
            context.getSystemService(NotificationManager::class.java)
                .notify(NOTIFICATION_ID, notification)
        }

        private fun createNotificationChannel(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Transcription",
                    NotificationManager.IMPORTANCE_LOW,
                )
                context.getSystemService(NotificationManager::class.java)
                    .createNotificationChannel(channel)
            }
        }

        private fun buildNotification(
            context: Context,
            title: String,
            progress: Int,
            max: Int,
            stage: String,
        ): Notification {
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            val pendingIntent = launchIntent?.let {
                PendingIntent.getActivity(
                    context,
                    1,
                    it,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
            }
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(context, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context)
            }
            return builder
                .setContentTitle(
                    if (stage == STAGE_SPEAKERS) {
                        "Detecting speakers — $title"
                    } else {
                        "Transcribing $title — $progress/$max"
                    },
                )
                .setContentText("ReXorder is processing audio offline")
                .setSmallIcon(android.R.drawable.ic_menu_info_details)
                .setOngoing(true)
                .setProgress(max, progress, max == 0)
                .setContentIntent(pendingIntent)
                .build()
        }
    }
}
