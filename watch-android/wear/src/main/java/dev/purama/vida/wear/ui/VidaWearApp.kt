package dev.purama.vida.wear.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import dev.purama.vida.wear.core.HealthConnectManager
import dev.purama.vida.wear.core.HealthSnapshot
import dev.purama.vida.wear.stores.IntentionStore
import dev.purama.vida.wear.stores.StreakStore
import dev.purama.vida.wear.ui.screens.BreathScreen
import dev.purama.vida.wear.ui.screens.DashboardScreen
import dev.purama.vida.wear.ui.screens.GratitudeScreen
import dev.purama.vida.wear.ui.screens.IntentionScreen
import dev.purama.vida.wear.ui.screens.RitualTimerScreen
import dev.purama.vida.wear.ui.screens.StreakScreen
import dev.purama.vida.wear.ui.theme.VidaWearTheme

/**
 * P8-F6 — Racine Wear OS : HorizontalPager 6 pages, equivalent de
 * TabView(.page) cote watchOS.
 */
@Composable
fun VidaWearApp(
    streakStore: StreakStore,
    intentionStore: IntentionStore,
    health: HealthConnectManager,
) {
    val streakState by streakStore.state.collectAsState()
    val intentionState by intentionStore.state.collectAsState()
    var snapshot by remember { mutableStateOf(HealthSnapshot.ZERO) }

    LaunchedEffect(Unit) {
        streakStore.refresh()
        intentionStore.refresh()
        snapshot = health.currentSnapshot()
    }

    VidaWearTheme {
        val pagerState = rememberPagerState(initialPage = 0, pageCount = { 6 })
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize(),
        ) { page ->
            when (page) {
                0 -> DashboardScreen(snapshot = snapshot, streak = streakState.streak)
                1 -> StreakScreen(
                    streak = streakState.streak,
                    gratitudeStreak = streakState.gratitudeStreak,
                )
                2 -> IntentionScreen(
                    intention = intentionState.currentIntention,
                    isLoading = intentionState.isLoading,
                    hasError = intentionState.lastError != null,
                )
                3 -> BreathScreen()
                4 -> GratitudeScreen(
                    gratitudeStreak = streakState.gratitudeStreak,
                    onSave = { /* F7 : envoi via DataClient vers phone */ },
                )
                5 -> RitualTimerScreen()
                else -> Unit
            }
        }
    }
}
