package com.main369.flutter_local_notifications_project
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("NotificationReceiver", "onReceive triggered")

        val notificationId = intent.getIntExtra("notification_id", 1001)
        val title = intent.getStringExtra("notification_title") ?: "Reminder"
        val body = intent.getStringExtra("notification_body") ?: "It's time!"
        val builder = NotificationCompat.Builder(context, "default_channel")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)

        NotificationManagerCompat.from(context).notify(notificationId, builder.build())
    }
}
