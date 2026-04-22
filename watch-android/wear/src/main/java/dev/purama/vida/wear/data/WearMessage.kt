package dev.purama.vida.wear.data

import dev.purama.vida.wear.core.HealthSnapshot
import org.json.JSONObject

/**
 * P8-F7 — Miroir Kotlin du WatchMessage Swift. Serialise en JSON pour
 * transit via Wearable MessageClient / DataClient.
 *
 * Contrat : meme format que l'iOS, valeurs typees "type": "xxx" + payload.
 */
sealed class WearMessage {
    data class AuthTokenUpdate(val token: String) : WearMessage()
    data class StreakUpdate(val streak: Int, val gratitudeStreak: Int) : WearMessage()
    data class IntentionUpdate(val text: String) : WearMessage()
    data class GratitudeCapture(val text: String, val capturedAt: Long) : WearMessage()
    data class HealthSnapshotPush(val snapshot: HealthSnapshot) : WearMessage()
    data object SyncRequest : WearMessage()
    data class RitualStarted(val durationSeconds: Int) : WearMessage()
    data class RitualCompleted(val durationSeconds: Int) : WearMessage()

    fun encode(): String = when (this) {
        is AuthTokenUpdate -> JSONObject().apply {
            put("type", "authTokenUpdate"); put("token", token)
        }.toString()
        is StreakUpdate -> JSONObject().apply {
            put("type", "streakUpdate"); put("streak", streak); put("gratitudeStreak", gratitudeStreak)
        }.toString()
        is IntentionUpdate -> JSONObject().apply {
            put("type", "intentionUpdate"); put("text", text)
        }.toString()
        is GratitudeCapture -> JSONObject().apply {
            put("type", "gratitudeCapture"); put("text", text); put("capturedAt", capturedAt)
        }.toString()
        is HealthSnapshotPush -> JSONObject().apply {
            put("type", "healthSnapshotPush")
            put("snapshot", JSONObject().apply {
                put("stepsToday", snapshot.stepsToday)
                put("heartRateBpm", snapshot.heartRateBpm ?: JSONObject.NULL)
                put("mindfulMinutesToday", snapshot.mindfulMinutesToday)
                put("activeCaloriesToday", snapshot.activeCaloriesToday)
                put("sleepHoursLastNight", snapshot.sleepHoursLastNight ?: JSONObject.NULL)
                put("capturedAt", snapshot.capturedAt)
            })
        }.toString()
        is SyncRequest -> JSONObject().apply { put("type", "syncRequest") }.toString()
        is RitualStarted -> JSONObject().apply {
            put("type", "ritualStarted"); put("durationSeconds", durationSeconds)
        }.toString()
        is RitualCompleted -> JSONObject().apply {
            put("type", "ritualCompleted"); put("durationSeconds", durationSeconds)
        }.toString()
    }

    companion object {
        fun decode(raw: String): WearMessage? = runCatching {
            val obj = JSONObject(raw)
            when (obj.getString("type")) {
                "authTokenUpdate" -> AuthTokenUpdate(obj.getString("token"))
                "streakUpdate" -> StreakUpdate(
                    streak = obj.getInt("streak"),
                    gratitudeStreak = obj.getInt("gratitudeStreak"),
                )
                "intentionUpdate" -> IntentionUpdate(obj.getString("text"))
                "gratitudeCapture" -> GratitudeCapture(
                    text = obj.getString("text"),
                    capturedAt = obj.getLong("capturedAt"),
                )
                "healthSnapshotPush" -> {
                    val s = obj.getJSONObject("snapshot")
                    HealthSnapshotPush(
                        HealthSnapshot(
                            stepsToday = s.getInt("stepsToday"),
                            heartRateBpm = s.optDouble("heartRateBpm").takeIf { !it.isNaN() },
                            mindfulMinutesToday = s.getInt("mindfulMinutesToday"),
                            activeCaloriesToday = s.getDouble("activeCaloriesToday"),
                            sleepHoursLastNight = s.optDouble("sleepHoursLastNight").takeIf { !it.isNaN() },
                            capturedAt = s.getLong("capturedAt"),
                        ),
                    )
                }
                "syncRequest" -> SyncRequest
                "ritualStarted" -> RitualStarted(obj.getInt("durationSeconds"))
                "ritualCompleted" -> RitualCompleted(obj.getInt("durationSeconds"))
                else -> null
            }
        }.getOrNull()
    }
}

const val WEAR_MESSAGE_PATH = "/vida/message"
