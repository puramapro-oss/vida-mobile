package dev.purama.vida.wear.complications

import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.MonochromaticImage
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.RangedValueComplicationData
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import dev.purama.vida.wear.tiles.VidaTileService

/**
 * P8-F7 — Complication Streak. Families : SHORT_TEXT + RANGED_VALUE.
 * Source : meme SharedPrefs que la Tile (ecrit par stores apres refresh).
 */
class StreakComplicationService : SuspendingComplicationDataSourceService() {

    override fun getPreviewData(type: ComplicationType): ComplicationData? {
        return when (type) {
            ComplicationType.SHORT_TEXT -> buildShortText(7)
            ComplicationType.RANGED_VALUE -> buildRanged(7)
            else -> null
        }
    }

    override suspend fun onComplicationRequest(
        request: ComplicationRequest,
    ): ComplicationData? {
        val snap = VidaTileService.readSnapshot(applicationContext)
        return when (request.complicationType) {
            ComplicationType.SHORT_TEXT -> buildShortText(snap.streak)
            ComplicationType.RANGED_VALUE -> buildRanged(snap.streak)
            else -> null
        }
    }

    private fun buildShortText(streak: Int): ShortTextComplicationData =
        ShortTextComplicationData.Builder(
            text = PlainComplicationText.Builder("🔥$streak").build(),
            contentDescription = PlainComplicationText.Builder("Streak VIDA $streak jours").build(),
        ).build()

    private fun buildRanged(streak: Int): RangedValueComplicationData {
        val value = streak.coerceAtMost(30).toFloat()
        return RangedValueComplicationData.Builder(
            value = value,
            min = 0f,
            max = 30f,
            contentDescription = PlainComplicationText.Builder("Streak VIDA $streak jours").build(),
        )
            .setText(PlainComplicationText.Builder("🔥$streak").build())
            .build()
    }
}
