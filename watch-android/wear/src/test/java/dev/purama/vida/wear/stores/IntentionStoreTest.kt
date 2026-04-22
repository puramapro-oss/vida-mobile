package dev.purama.vida.wear.stores

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate

class IntentionStoreTest {

    @Test
    fun deterministicFallback_sameDay_sameValue() {
        val date = LocalDate.of(2026, 4, 22)
        val list = listOf("a", "b", "c")
        val a = IntentionStore.deterministicFallback(list, date)
        val b = IntentionStore.deterministicFallback(list, date)
        assertEquals(a, b)
        assertTrue(a in list)
    }

    @Test
    fun deterministicFallback_nextDay_changesValue() {
        val list = listOf("a", "b", "c", "d", "e", "f", "g", "h", "i", "j")
        val a = IntentionStore.deterministicFallback(list, LocalDate.of(2026, 4, 22))
        val b = IntentionStore.deterministicFallback(list, LocalDate.of(2026, 4, 23))
        assertNotEquals(a, b)
    }

    @Test
    fun deterministicFallback_emptyList_returnsRespire() {
        val v = IntentionStore.deterministicFallback(emptyList(), LocalDate.now())
        assertEquals("Respire.", v)
    }

    @Test
    fun defaultFallbacks_haveAtLeastThreeItems() {
        assertTrue(IntentionStore.DEFAULT_FALLBACKS.size >= 3)
        for (s in IntentionStore.DEFAULT_FALLBACKS) {
            assertTrue(s.isNotEmpty())
        }
    }
}
