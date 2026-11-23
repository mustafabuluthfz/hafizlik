package __PACKAGE__

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class VakitWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val satirlar = prefs.getString("flutter.widget_satirlar", null)
            ?.split("|")
            ?.joinToString("   ·   ")
            ?: "Vakitler için uygulamayı açın"
        val sonrakiAd = prefs.getString("flutter.widget_sonraki_ad", "") ?: ""
        val sonrakiSaat = prefs.getString("flutter.widget_sonraki_saat", "--:--") ?: "--:--"

        val acilis = context.packageManager.getLaunchIntentForPackage(context.packageName)

        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.vakit_widget)
            views.setTextViewText(R.id.sonraki_ad, "Sıradaki: $sonrakiAd")
            views.setTextViewText(R.id.sonraki_saat, sonrakiSaat)
            views.setTextViewText(R.id.satirlar, satirlar)
            if (acilis != null) {
                val pi = PendingIntent.getActivity(context, 0, acilis, PendingIntent.FLAG_IMMUTABLE)
                views.setOnClickPendingIntent(R.id.kok, pi)
            }
            manager.updateAppWidget(id, views)
        }
    }
}
