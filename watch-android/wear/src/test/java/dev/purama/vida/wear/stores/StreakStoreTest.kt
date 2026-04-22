package dev.purama.vida.wear.stores

import android.content.Context
import android.content.SharedPreferences
import dev.purama.vida.wear.core.SupabaseClient
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class StreakStoreTest {

    private fun makeClient(): SupabaseClient {
        val context = mockk<Context>(relaxed = true)
        val prefs = mockk<SharedPreferences>(relaxed = true) {
            every { getString(any(), any()) } returns null
        }
        every { context.getSharedPreferences(any(), any()) } returns prefs
        return SupabaseClient(context)
    }

    @Test
    fun initialState_isZero() {
        val store = StreakStore(makeClient())
        val s = store.state.value
        assertEquals(0, s.streak)
        assertEquals(0, s.gratitudeStreak)
        assertNull(s.lastRefreshedAt)
        assertNull(s.lastError)
    }

    @Test
    fun applyRemoteUpdate_setsAllFields() {
        val store = StreakStore(makeClient())
        store.applyRemoteUpdate(streak = 12, gratitudeStreak = 7)
        val s = store.state.value
        assertEquals(12, s.streak)
        assertEquals(7, s.gratitudeStreak)
        assertNotNull(s.lastRefreshedAt)
    }

    @Test
    fun refresh_withoutToken_setsError() = runTest {
        val store = StreakStore(makeClient())
        store.refresh()
        val s = store.state.value
        // pas de token en SharedPrefs mockees -> SupabaseException -> lastError non null
        assertNotNull(s.lastError)
        assertEquals(false, s.isLoading)
    }
}
