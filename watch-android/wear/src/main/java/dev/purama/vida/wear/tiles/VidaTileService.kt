package dev.purama.vida.wear.tiles

import android.content.Context
import android.content.SharedPreferences
import androidx.wear.protolayout.ColorBuilders.argb
import androidx.wear.protolayout.DimensionBuilders.dp
import androidx.wear.protolayout.DimensionBuilders.sp
import androidx.wear.protolayout.LayoutElementBuilders
import androidx.wear.protolayout.LayoutElementBuilders.Column
import androidx.wear.protolayout.LayoutElementBuilders.FontStyle
import androidx.wear.protolayout.LayoutElementBuilders.LayoutElement
import androidx.wear.protolayout.LayoutElementBuilders.Spacer
import androidx.wear.protolayout.LayoutElementBuilders.Text
import androidx.wear.protolayout.ResourceBuilders
import androidx.wear.protolayout.TimelineBuilders
import androidx.wear.tiles.RequestBuilders
import androidx.wear.tiles.TileBuilders
import androidx.wear.tiles.TileService
import com.google.android.gms.tasks.Tasks
import com.google.common.util.concurrent.ListenableFuture
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.guava.asListenableFuture

/**
 * P8-F7 — Tile Wear OS principale. Affiche streak + steps + intention snippet.
 * Rafraichi toutes les 15 minutes via freshnessIntervalMillis.
 */
class VidaTileService : TileService() {

    override fun onTileRequest(
        requestParams: RequestBuilders.TileRequest,
    ): ListenableFuture<TileBuilders.Tile> =
        CoroutineScope(Dispatchers.Default).async { buildTile() }.asListenableFuture()

    override fun onTileResourcesRequest(
        requestParams: RequestBuilders.ResourcesRequest,
    ): ListenableFuture<ResourceBuilders.Resources> =
        CoroutineScope(Dispatchers.Default).async {
            ResourceBuilders.Resources.Builder().setVersion(RESOURCE_VERSION).build()
        }.asListenableFuture()

    private fun buildTile(): TileBuilders.Tile {
        val snapshot = readSnapshot(applicationContext)
        val layout = LayoutElementBuilders.Layout.Builder()
            .setRoot(buildLayout(snapshot))
            .build()
        val timeline = TimelineBuilders.Timeline.fromLayoutElement(
            LayoutElementBuilders.Box.Builder().addContent(buildLayout(snapshot)).build(),
        )
        return TileBuilders.Tile.Builder()
            .setResourcesVersion(RESOURCE_VERSION)
            .setFreshnessIntervalMillis(FRESHNESS_MS)
            .setTileTimeline(timeline)
            .build()
    }

    private fun buildLayout(snapshot: TileSnapshot): LayoutElement {
        return Column.Builder()
            .addContent(
                Text.Builder()
                    .setText("🔥 ${snapshot.streak} j")
                    .setFontStyle(
                        FontStyle.Builder()
                            .setSize(sp(24f))
                            .setColor(argb(0xFFFA9447.toInt()))
                            .build(),
                    )
                    .build(),
            )
            .addContent(Spacer.Builder().setHeight(dp(6f)).build())
            .addContent(
                Text.Builder()
                    .setText("${snapshot.stepsToday} pas")
                    .setFontStyle(
                        FontStyle.Builder()
                            .setSize(sp(14f))
                            .setColor(argb(0xFFF5F5F5.toInt()))
                            .build(),
                    )
                    .build(),
            )
            .addContent(Spacer.Builder().setHeight(dp(4f)).build())
            .addContent(
                Text.Builder()
                    .setText(snapshot.intention.take(40))
                    .setMaxLines(2)
                    .setFontStyle(
                        FontStyle.Builder()
                            .setSize(sp(11f))
                            .setColor(argb(0xAFF5F5F5.toInt()))
                            .build(),
                    )
                    .build(),
            )
            .build()
    }

    companion object {
        const val RESOURCE_VERSION = "1"
        const val FRESHNESS_MS = 15L * 60L * 1000L // 15 min
        const val PREFS = "vida.wear.tiles"
        const val STREAK_KEY = "streak"
        const val GRATITUDE_KEY = "gratitude_streak"
        const val STEPS_KEY = "steps_today"
        const val INTENTION_KEY = "intention"

        fun writeSnapshot(context: Context, snapshot: TileSnapshot) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putInt(STREAK_KEY, snapshot.streak)
                putInt(GRATITUDE_KEY, snapshot.gratitudeStreak)
                putInt(STEPS_KEY, snapshot.stepsToday)
                putString(INTENTION_KEY, snapshot.intention)
            }.apply()
        }

        fun readSnapshot(context: Context): TileSnapshot {
            val prefs: SharedPreferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            return TileSnapshot(
                streak = prefs.getInt(STREAK_KEY, 0),
                gratitudeStreak = prefs.getInt(GRATITUDE_KEY, 0),
                stepsToday = prefs.getInt(STEPS_KEY, 0),
                intention = prefs.getString(INTENTION_KEY, "Respire.") ?: "Respire.",
            )
        }
    }
}

data class TileSnapshot(
    val streak: Int = 0,
    val gratitudeStreak: Int = 0,
    val stepsToday: Int = 0,
    val intention: String = "Respire.",
)
