package com.example.labodc_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Android Widget Provider cho LabODC Notification Widget
 * 
 * Widget hiển thị số lượng thông báo chưa đọc trên màn hình chính
 * Data được cập nhật từ Flutter app thông qua home_widget package
 */
class NotificationWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // Update tất cả các widget instances
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.notification_widget)

            // Lấy data từ SharedPreferences (được set từ Flutter)
            val unreadCount = widgetData.getInt("unread_count", 0)
            val lastUpdated = widgetData.getString("last_updated", "--:--")

            // Update các TextViews
            views.setTextViewText(R.id.unread_count, unreadCount.toString())
            
            // Format last updated text
            val updateText = if (lastUpdated != "--:--") {
                "Cập nhật: $lastUpdated"
            } else {
                "Chưa có dữ liệu"
            }
            views.setTextViewText(R.id.last_updated, updateText)

            // Tạo PendingIntent để mở app với deep link
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("labodc://notifications")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
            )
            
            // Tap vào toàn bộ widget để mở app
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            // Update widget
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
