package dev.purama.vida.wear.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import dev.purama.vida.wear.core.HealthSnapshot
import dev.purama.vida.wear.ui.theme.VidaColors
import dev.purama.vida.wear.ui.theme.VidaWearTheme

/**
 * P8-F6 — 3 anneaux concentriques steps / mindful / calories + HR + streak.
 * Emoji inline (pas d'Icons Material pour rester sur deps Wear pures).
 */
@Composable
fun DashboardScreen(
    snapshot: HealthSnapshot,
    streak: Int,
) {
    Column(
        modifier = Modifier.fillMaxSize().padding(8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Box(
            modifier = Modifier.size(110.dp),
            contentAlignment = Alignment.Center,
        ) {
            CircularProgressIndicator(
                progress = snapshot.caloriesProgress.toFloat(),
                modifier = Modifier.size(110.dp),
                indicatorColor = VidaColors.WarmOrange,
                trackColor = VidaColors.OnDark.copy(alpha = 0.12f),
                strokeWidth = 5.dp,
            )
            CircularProgressIndicator(
                progress = snapshot.mindfulProgress.toFloat(),
                modifier = Modifier.size(88.dp),
                indicatorColor = VidaColors.DeepViolet,
                trackColor = VidaColors.OnDark.copy(alpha = 0.12f),
                strokeWidth = 5.dp,
            )
            CircularProgressIndicator(
                progress = snapshot.stepsProgress.toFloat(),
                modifier = Modifier.size(66.dp),
                indicatorColor = VidaColors.Emerald,
                trackColor = VidaColors.OnDark.copy(alpha = 0.12f),
                strokeWidth = 5.dp,
            )
        }
        Spacer(modifier = Modifier.height(6.dp))
        Row(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "👟 ${snapshot.stepsToday}",
                style = MaterialTheme.typography.caption2,
                color = VidaColors.OnDark,
            )
            snapshot.heartRateBpm?.let {
                Text(
                    text = "❤️ ${it.toInt()}",
                    style = MaterialTheme.typography.caption2,
                    color = VidaColors.WarmOrange,
                )
            }
        }
        Spacer(modifier = Modifier.height(2.dp))
        Text(
            text = "🔥 $streak j",
            style = MaterialTheme.typography.caption2,
            color = VidaColors.Emerald,
        )
    }
}

@Preview(widthDp = 192, heightDp = 192, showBackground = true, backgroundColor = 0xFF0A0A0F)
@Composable
fun DashboardPreview() {
    VidaWearTheme {
        DashboardScreen(
            snapshot = HealthSnapshot(
                stepsToday = 4800,
                heartRateBpm = 72.0,
                mindfulMinutesToday = 6,
                activeCaloriesToday = 220.0,
                sleepHoursLastNight = 7.0,
            ),
            streak = 7,
        )
    }
}
