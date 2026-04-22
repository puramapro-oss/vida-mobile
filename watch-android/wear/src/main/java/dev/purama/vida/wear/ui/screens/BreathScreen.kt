package dev.purama.vida.wear.ui.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import dev.purama.vida.wear.ui.theme.VidaColors
import dev.purama.vida.wear.ui.theme.VidaWearTheme
import dev.purama.vida.wear.util.vibrateClick
import dev.purama.vida.wear.util.vibrateStart
import dev.purama.vida.wear.util.vibrateSuccess
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private enum class BreathPhase(val label: String, val durationMs: Long, val targetScale: Float) {
    INHALE("Inspire", 4_000, 1.0f),
    HOLD("Tiens", 4_000, 1.0f),
    EXHALE("Expire", 6_000, 0.4f);

    fun next(): BreathPhase = when (this) {
        INHALE -> HOLD
        HOLD -> EXHALE
        EXHALE -> INHALE
    }
}

@Composable
fun BreathScreen() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var isRunning by remember { mutableStateOf(false) }
    var phase by remember { mutableStateOf(BreathPhase.INHALE) }
    var completedCycles by remember { mutableIntStateOf(0) }

    val scale by animateFloatAsState(
        targetValue = if (isRunning) phase.targetScale else 0.4f,
        animationSpec = tween(durationMillis = phase.durationMs.toInt()),
        label = "breathScale",
    )

    LaunchedEffect(isRunning, phase) {
        if (!isRunning) return@LaunchedEffect
        delay(phase.durationMs)
        if (phase == BreathPhase.EXHALE) completedCycles += 1
        vibrateClick(context)
        phase = phase.next()
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Box(
            modifier = Modifier.size(100.dp),
            contentAlignment = Alignment.Center,
        ) {
            Box(
                modifier = Modifier
                    .size(90.dp)
                    .clip(CircleShape)
                    .background(VidaColors.EmeraldSoft),
            )
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .scale(scale)
                    .clip(CircleShape)
                    .background(VidaColors.Emerald.copy(alpha = 0.55f)),
            )
            Text(
                text = if (isRunning) phase.label else "Prêt",
                style = MaterialTheme.typography.caption1,
                color = VidaColors.OnDark,
            )
        }
        if (isRunning) {
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Cycles : $completedCycles",
                style = MaterialTheme.typography.caption2,
                color = VidaColors.OnDark.copy(alpha = 0.65f),
            )
        }
        Spacer(modifier = Modifier.height(6.dp))
        Button(
            onClick = {
                if (isRunning) {
                    isRunning = false
                    scope.launch { vibrateSuccess(context) }
                } else {
                    completedCycles = 0
                    phase = BreathPhase.INHALE
                    isRunning = true
                    scope.launch { vibrateStart(context) }
                }
            },
            colors = ButtonDefaults.primaryButtonColors(
                backgroundColor = VidaColors.Emerald,
                contentColor = VidaColors.Dark,
            ),
        ) {
            Text(if (isRunning) "Stop" else "Démarrer")
        }
    }
}

@Preview(widthDp = 192, heightDp = 192, showBackground = true, backgroundColor = 0xFF0A0A0F)
@Composable
fun BreathPreview() {
    VidaWearTheme { BreathScreen() }
}
