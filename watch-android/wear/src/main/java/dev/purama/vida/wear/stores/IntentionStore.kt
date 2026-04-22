package dev.purama.vida.wear.stores

import dev.purama.vida.wear.core.SupabaseClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.time.LocalDate
import java.time.ZoneId

/**
 * P8-F6 — Miroir Kotlin de IntentionStore Swift.
 */
class IntentionStore(
    private val client: SupabaseClient,
    private val fallbacks: List<String> = DEFAULT_FALLBACKS,
) {
    data class State(
        val currentIntention: String,
        val lastRefreshedAt: Long? = null,
        val isLoading: Boolean = false,
        val lastError: String? = null,
    )

    private val _state = MutableStateFlow(
        State(currentIntention = deterministicFallback(fallbacks, LocalDate.now()))
    )
    val state: StateFlow<State> = _state.asStateFlow()

    suspend fun refresh() {
        _state.value = _state.value.copy(isLoading = true, lastError = null)
        try {
            val profile = client.fetchProfile()
            val text = profile.currentIntention?.takeIf { it.isNotBlank() }
                ?: deterministicFallback(fallbacks, LocalDate.now())
            _state.value = State(
                currentIntention = text,
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

    fun applyRemoteUpdate(text: String) {
        _state.value = _state.value.copy(
            currentIntention = text,
            lastRefreshedAt = System.currentTimeMillis(),
        )
    }

    companion object {
        val DEFAULT_FALLBACKS = listOf(
            "Respire. Tu fais de ton mieux, et c'est deja beaucoup.",
            "Aujourd'hui, choisis un petit geste de douceur envers toi-meme.",
            "Ton corps garde la sagesse. Ecoute-le.",
            "Chaque pas, meme lent, te rapproche de toi.",
            "Le silence est aussi une reponse.",
            "Tu n'as rien a prouver. Juste a etre.",
        )

        fun deterministicFallback(list: List<String>, date: LocalDate): String {
            if (list.isEmpty()) return "Respire."
            val dayOfYear = date.atStartOfDay(ZoneId.systemDefault()).toLocalDate().dayOfYear
            return list[dayOfYear % list.size]
        }
    }
}
