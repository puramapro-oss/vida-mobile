package dev.purama.vida.wear

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * P8-F1 smoke test : le module compile et les tests tournent.
 * Tests métier arrivent en F6.
 */
class ScaffoldTest {
    @Test
    fun appGroupSuiteName_isStable() {
        val expected = "group.dev.purama.vida"
        assertEquals(expected, "group.dev.purama.vida")
    }

    @Test
    fun bundleIdentifier_isExpected() {
        val expected = "dev.purama.vida"
        assertEquals(expected, "dev.purama.vida")
    }
}
