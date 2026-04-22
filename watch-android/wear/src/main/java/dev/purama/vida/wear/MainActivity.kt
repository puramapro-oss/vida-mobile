package dev.purama.vida.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import dev.purama.vida.wear.core.HealthConnectManager
import dev.purama.vida.wear.core.SupabaseClient
import dev.purama.vida.wear.stores.IntentionStore
import dev.purama.vida.wear.stores.StreakStore
import dev.purama.vida.wear.ui.VidaWearApp

/**
 * P8-F6 — Composition root Wear OS. Branche stores + health, lance VidaWearApp.
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val client = SupabaseClient(context = applicationContext)
        val streak = StreakStore(client)
        val intention = IntentionStore(client)
        val health = HealthConnectManager(applicationContext)
        setContent {
            VidaWearApp(
                streakStore = streak,
                intentionStore = intention,
                health = health,
            )
        }
    }
}
