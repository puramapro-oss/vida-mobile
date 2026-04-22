package dev.purama.vida.wear.core

import kotlin.math.min

/**
 * P8-F6 — Miroir Kotlin du HealthSnapshot Swift. Meme contrat pour
 * transiter via DataClient (F7) et etre decode cote phone / Supabase.
 */
data class HealthSnapshot(
    val stepsToday: Int,
    val heartRateBpm: Double?,
    val mindfulMinutesToday: Int,
    val activeCaloriesToday: Double,
    val sleepHoursLastNight: Double?,
    val capturedAt: Long = System.currentTimeMillis(),
) {
    val stepsProgress: Double get() = min(1.0, stepsToday / 8_000.0)
    val mindfulProgress: Double get() = min(1.0, mindfulMinutesToday / 10.0)
    val caloriesProgress: Double get() = min(1.0, activeCaloriesToday / 400.0)

    companion object {
        val ZERO = HealthSnapshot(
            stepsToday = 0,
            heartRateBpm = null,
            mindfulMinutesToday = 0,
            activeCaloriesToday = 0.0,
            sleepHoursLastNight = null,
        )
    }
}

data class WatchProfile(
    val streak: Int,
    val currentIntention: String?,
    val gratitudeStreak: Int,
)
