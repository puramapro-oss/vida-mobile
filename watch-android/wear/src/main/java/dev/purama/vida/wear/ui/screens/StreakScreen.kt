package dev.purama.vida.wear.ui.screens

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import dev.purama.vida.wear.ui.theme.VidaColors
import dev.purama.vida.wear.ui.theme.VidaWearTheme
import dev.purama.vida.wear.util.vibrateSuccess

@Composable
fun StreakScreen(
    streak: Int,
    gratitudeStreak: Int,
) {
    val context = LocalContext.current
    val scale by animateFloatAsState(
        targetValue = if (streak > 0) 1.0f else 0.8f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioLowBouncy),
        label = "streakScale",
    )

    LaunchedEffect(streak) {
        if (streak > 0) vibrateSuccess(context)
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text(
            text = "🔥",
            fontSize = 44.sp,
            modifier = Modifier.scale(scale),
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "$streak jour${if (streak > 1) "s" else ""}",
            style = MaterialTheme.typography.title3,
            color = VidaColors.WarmOrange,
        )
        Text(
            text = "de suite",
            style = MaterialTheme.typography.caption2,
            color = VidaColors.OnDark.copy(alpha = 0.65f),
        )
        if (gratitudeStreak > 0) {
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = "💜 $gratitudeStreak gratitudes",
                style = MaterialTheme.typography.caption2,
                color = VidaColors.Emerald,
            )
        }
    }
}

@Preview(widthDp = 192, heightDp = 192, showBackground = true, backgroundColor = 0xFF0A0A0F)
@Composable
fun StreakPreview() {
    VidaWearTheme {
        StreakScreen(streak = 12, gratitudeStreak = 5)
    }
}
