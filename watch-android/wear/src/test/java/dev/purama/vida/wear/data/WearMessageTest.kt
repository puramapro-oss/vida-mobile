package dev.purama.vida.wear.data

import dev.purama.vida.wear.core.HealthSnapshot
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class WearMessageTest {

    @Test
    fun authTokenUpdate_roundTrip() {
        val msg: WearMessage = WearMessage.AuthTokenUpdate("jwt-abc")
        val decoded = WearMessage.decode(msg.encode())
        assertTrue(decoded is WearMessage.AuthTokenUpdate)
        assertEquals("jwt-abc", (decoded as WearMessage.AuthTokenUpdate).token)
    }

    @Test
    fun streakUpdate_roundTrip() {
        val msg: WearMessage = WearMessage.StreakUpdate(streak = 14, gratitudeStreak = 5)
        val decoded = WearMessage.decode(msg.encode()) as WearMessage.StreakUpdate
        assertEquals(14, decoded.streak)
        assertEquals(5, decoded.gratitudeStreak)
    }

    @Test
    fun intentionUpdate_roundTrip() {
        val msg: WearMessage = WearMessage.IntentionUpdate("Bois un verre d'eau.")
        val decoded = WearMessage.decode(msg.encode()) as WearMessage.IntentionUpdate
        assertEquals("Bois un verre d'eau.", decoded.text)
    }

    @Test
    fun gratitudeCapture_roundTrip() {
        val ts = 1_700_000_000_000L
        val msg: WearMessage = WearMessage.GratitudeCapture("Merci", ts)
        val decoded = WearMessage.decode(msg.encode()) as WearMessage.GratitudeCapture
        assertEquals("Merci", decoded.text)
        assertEquals(ts, decoded.capturedAt)
    }

    @Test
    fun healthSnapshotPush_roundTripKeepsFields() {
        val snap = HealthSnapshot(
            stepsToday = 5_200,
            heartRateBpm = 72.5,
            mindfulMinutesToday = 8,
            activeCaloriesToday = 310.0,
            sleepHoursLastNight = 7.2,
            capturedAt = 1_700_000_000_000L,
        )
        val msg: WearMessage = WearMessage.HealthSnapshotPush(snap)
        val decoded = WearMessage.decode(msg.encode()) as WearMessage.HealthSnapshotPush
        assertEquals(snap.stepsToday, decoded.snapshot.stepsToday)
        assertEquals(snap.heartRateBpm, decoded.snapshot.heartRateBpm)
        assertEquals(snap.mindfulMinutesToday, decoded.snapshot.mindfulMinutesToday)
        assertEquals(snap.activeCaloriesToday, decoded.snapshot.activeCaloriesToday, 0.001)
        assertEquals(snap.sleepHoursLastNight, decoded.snapshot.sleepHoursLastNight)
        assertEquals(snap.capturedAt, decoded.snapshot.capturedAt)
    }

    @Test
    fun healthSnapshotPush_nullsPreserved() {
        val snap = HealthSnapshot(
            stepsToday = 100,
            heartRateBpm = null,
            mindfulMinutesToday = 0,
            activeCaloriesToday = 0.0,
            sleepHoursLastNight = null,
            capturedAt = 0,
        )
        val msg: WearMessage = WearMessage.HealthSnapshotPush(snap)
        val decoded = WearMessage.decode(msg.encode()) as WearMessage.HealthSnapshotPush
        assertNull(decoded.snapshot.heartRateBpm)
        assertNull(decoded.snapshot.sleepHoursLastNight)
    }

    @Test
    fun syncRequest_roundTrip() {
        val decoded = WearMessage.decode(WearMessage.SyncRequest.encode())
        assertTrue(decoded is WearMessage.SyncRequest)
    }

    @Test
    fun ritualStarted_roundTrip() {
        val decoded = WearMessage.decode(
            WearMessage.RitualStarted(durationSeconds = 180).encode(),
        ) as WearMessage.RitualStarted
        assertEquals(180, decoded.durationSeconds)
    }

    @Test
    fun decode_malformed_returnsNull() {
        assertNull(WearMessage.decode("not-json"))
        assertNull(WearMessage.decode("{\"type\": \"unknown\"}"))
        assertNull(WearMessage.decode("{}"))
    }

    @Test
    fun wearMessagePath_isStable() {
        assertEquals("/vida/message", WEAR_MESSAGE_PATH)
    }
}
