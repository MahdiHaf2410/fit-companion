package com.fitcompanion.fit_companion

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Home-screen widget: calories left, protein and water for today. Data is pushed from Flutter. */
class FitWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.fit_widget).apply {
                setTextViewText(R.id.widget_title, widgetData.getString("w_title", "Fit Companion"))
                setTextViewText(R.id.widget_kcal, widgetData.getString("w_kcal", "—"))
                setTextViewText(R.id.widget_kcal_label, widgetData.getString("w_kcal_label", "kcal left"))
                setTextViewText(R.id.widget_protein, widgetData.getString("w_protein", "—"))
                setTextViewText(R.id.widget_water, widgetData.getString("w_water", "—"))
                setProgressBar(R.id.widget_progress, 100, widgetData.getInt("w_progress", 0), false)
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
