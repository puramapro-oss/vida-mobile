package dev.purama.vida.wear.stores

import dev.purama.vida.wear.core.SupabaseClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * P8-F6 — Miroir Kotlin du StreakStore Swift. StateFlow-based pour Compose
 * collectAsStateWithLifecycle.
 */
class StreakStore(private val client: SupabaseClient) {

    data class State(
        val streak: Int = 0,
        val gratitudeStreak: Int = 0,
        val lastRefreshedAt: Long? = null,
        val isLoading: Boolean = false,
        val lastError: String? = null,
    )

    private val _state = MutableStateFlow(State())
    val state: StateFlow<State> = _state.asStateFlow()

    suspend fun refresh() {
        _state.value = _state.value.copy(isLoading = true, lastError = null)
        try {
            val profile = client.fetchProfile()
            _state.value = State(
                streak = profile.streak,
                gratitudeStreak = profile.gratitudeStreak,
                lastRefreshedAt = System.currentTimeMillis(),
                isLoading = false,
                lastError = null,
            )
        } catch (t: Throwable) {
            _state.value = _state.value.copy(
                isLoading = false,
                lastError = t.message ?: "Erreur reseau",
            )
        }
    }

    fun applyRemoteUpdate(streak: Int, gratitudeStreak: Int) {
        _state.value = _state.value.copy(
            streak = streak,
            gratitudeStreak = gratitudeStreak,
            lastRefreshedAt = System.currentTimeMillis(),
        )
    }
}
