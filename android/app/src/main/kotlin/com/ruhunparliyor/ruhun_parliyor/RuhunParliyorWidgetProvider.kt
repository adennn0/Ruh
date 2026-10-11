package com.ruhunparliyor.ruhun_parliyor

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Bundle
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import es.antonborri.home_widget.HomeWidgetProvider

class RuhunParliyorWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId, widgetData)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        updateWidget(
            context,
            appWidgetManager,
            appWidgetId,
            es.antonborri.home_widget.HomeWidgetPlugin.getData(context),
        )
    }

    private fun updateWidget(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        data: SharedPreferences,
    ) {
        val options = manager.getAppWidgetOptions(widgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
        val layout = if (minWidth >= 250) {
            R.layout.ruhun_widget_wide
        } else {
            R.layout.ruhun_widget_small
        }
        val views = RemoteViews(context.packageName, layout)
        val colors = data.getString("accentColors", "")
            ?.split(',')
            .orEmpty()
        val background = colors.getOrNull(0)?.toColorOrNull() ?: Color.rgb(243, 240, 246)
        val foreground = colors.getOrNull(1)?.toColorOrNull() ?: Color.rgb(33, 27, 42)
        val accent = colors.getOrNull(2)?.toColorOrNull() ?: Color.rgb(102, 88, 121)
        views.setInt(R.id.widget_root, "setBackgroundColor", background)
        views.setTextColor(R.id.widget_headline, foreground)
        views.setTextColor(R.id.widget_label, accent)
        val privacyMode = data.getBoolean("privacyMode", true)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT).format(Date())
        val hasTodaySnapshot = data.getString("localDate", null) == today
        val headline = if (hasTodaySnapshot) {
            data.getString("headline", "Bugün kendine nazik davran.")
        } else {
            "Bugün kendine nazik davran."
        }
        views.setTextViewText(R.id.widget_headline, headline)

        if (layout == R.layout.ruhun_widget_wide) {
            val body = if (hasTodaySnapshot) {
                data.getString("body", "Küçük bir nefes arası iyi gelebilir.")
            } else {
                "Günün olumlaması ve mesajı için uygulamayı aç."
            }
            views.setTextViewText(R.id.widget_body, body)
            val phase = if (hasTodaySnapshot) {
                data.getString("moonPhaseLabel", "")?.takeIf { it.isNotBlank() }
            } else {
                null
            }
            val streak = data.getInt("streakCount", -1)
            val footer = buildList {
                if (phase != null) add(phase)
                if (!privacyMode && streak >= 0) add("Işık Serisi · $streak gün")
                if (data.getString("contentSource", "local") == "demo") {
                    add("Demo içerik")
                }
            }.joinToString("  ·  ")
            views.setTextViewText(R.id.widget_footer, footer)

            val secondary = colors.getOrNull(3)?.toColorOrNull() ?: Color.rgb(81, 71, 95)
            views.setTextColor(R.id.widget_body, secondary)
            views.setTextColor(R.id.widget_footer, secondary)
        }

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            widgetId,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        manager.updateAppWidget(widgetId, views)
    }

    private fun String.toColorOrNull(): Int? = try {
        Color.parseColor(this)
    } catch (_: IllegalArgumentException) {
        null
    }
}
