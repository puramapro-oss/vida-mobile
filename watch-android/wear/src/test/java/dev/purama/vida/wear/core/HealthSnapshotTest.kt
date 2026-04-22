package dev.purama.vida.wear.core

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class HealthSnapshotTest {

    @Test
    fun zeroSnapshot_hasNullAndZeroValues() {
        val z = HealthSnapshot.ZERO
        assertEquals(0, z.stepsToday)
        assertEquals(0, z.mindfulMinutesToday)
        assertEquals(0.0, z.activeCaloriesToday, 0.0001)
        assertNull(z.heartRateBpm)
        assertNull(z.sleepHoursLastNight)
        assertEquals(0.0, z.stepsProgress, 0.0001)
    }

    @Test
    fun stepsProgress_clampsAtOne() {
        val s = HealthSnapshot(
            stepsToday = 99_999, heartRateBpm = null,
            mindfulMinutesToday = 0, activeCaloriesToday = 0.0,
            sleepHoursLastNight = null,
        )
        assertEquals(1.0, s.stepsProgress, 0.0001)
    }

    @Test
    fun mindfulProgress_atFiveMinutesIsHalf() {
        val s = HealthSnapshot(
            stepsToday = 0, heartRateBpm = null,
            mindfulMinutesToday = 5, activeCaloriesToday = 0.0,
            sleepHoursLastNight = null,
        )
        assertEquals(0.5, s.mindfulProgress, 0.0001)
    }

    @Test
    fun caloriesProgress_atTwoHundredIsHalf() {
        val s = HealthSnapshot(
            stepsToday = 0, heartRateBpm = null,
            mindfulMinutesToday = 0, activeCaloriesToday = 200.0,
            sleepHoursLastNight = null,
        )
        assertEquals(0.5, s.caloriesProgress, 0.0001)
    }
}
