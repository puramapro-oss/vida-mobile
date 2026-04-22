package dev.purama.vida.wear.complications

import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.RangedValueComplicationData
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import dev.purama.vida.wear.tiles.VidaTileService

class StepsComplicationService : SuspendingComplicationDataSourceService() {

    override fun getPreviewData(type: ComplicationType): ComplicationData? = when (type) {
        ComplicationType.SHORT_TEXT -> shortText(4_200)
        ComplicationType.RANGED_VALUE -> ranged(4_200)
        else -> null
    }

    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val snap = VidaTileService.readSnapshot(applicationContext)
        return when (request.complicationType) {
            ComplicationType.SHORT_TEXT -> shortText(snap.stepsToday)
            ComplicationType.RANGED_VALUE -> ranged(snap.stepsToday)
            else -> null
        }
    }

    private fun shortText(steps: Int): ShortTextComplicationData =
        ShortTextComplicationData.Builder(
            text = PlainComplicationText.Builder(formatSteps(steps)).build(),
            contentDescription = PlainComplicationText.Builder("$steps pas aujourd'hui").build(),
        ).build()

    private fun ranged(steps: Int): RangedValueComplicationData {
        val goal = 8_000f
        val value = steps.toFloat().coerceAtMost(goal)
        return RangedValueComplicationData.Builder(
            value = value,
            min = 0f,
            max = goal,
            contentDescription = PlainComplicationText.Builder("$steps pas aujourd'hui").build(),
        )
            .setText(PlainComplicationText.Builder(formatSteps(steps)).build())
            .build()
    }

    private fun formatSteps(steps: Int): String =
        if (steps >= 1_000) "${steps / 1_000}K" else "$steps"
}
