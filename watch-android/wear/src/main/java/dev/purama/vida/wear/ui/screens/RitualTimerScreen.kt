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
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import dev.purama.vida.wear.ui.theme.VidaColors
import dev.purama.vida.wear.ui.theme.VidaWearTheme
import dev.purama.vida.wear.util.vibrateClick
import dev.purama.vida.wear.util.vibrateStart
import dev.purama.vida.wear.util.vibrateSuccess
import kotlinx.coroutines.delay

private val DURATIONS = listOf(60, 180, 300)

@Composable
fun RitualTimerScreen() {
    val context = LocalContext.current
    var selectedIndex by remember { mutableIntStateOf(1) }
    var isRunning by remember { mutableStateOf(false) }
    var remaining by remember { mutableIntStateOf(DURATIONS[1]) }

    LaunchedEffect(isRunning) {
        if (!isRunning) return@LaunchedEffect
        while (remaining > 0) {
            delay(1_000)
            remaining -= 1
            if (remaining > 0 && remaining % 60 == 0) vibrateClick(context)
        }
        if (isRunning) {
            isRunning = false
            vibrateSuccess(context)
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(10.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        if (!isRunning) {
            Text(
                text = "Rituel silence",
                style = MaterialTheme.typography.caption1,
                color = VidaColors.OnDark.copy(alpha = 0.65f),
            )
            Spacer(modifier = Modifier.height(6.dp))
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                DURATIONS.forEachIndexed { index, sec ->
                    Button(
                        onClick = { selectedIndex = index; remaining = sec },
                        colors = ButtonDefaults.primaryButtonColors(
                            backgroundColor = if (index == selectedIndex)
                                VidaColors.DeepViolet else VidaColors.Dark,
                            contentColor = VidaColors.OnDark,
                        ),
                    ) {
                        Text("${sec / 60}m", style = MaterialTheme.typography.caption2)
                    }
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
            Button(
                onClick = {
                    remaining = DURATIONS[selectedIndex]
                    isRunning = true
                    vibrateStart(context)
                },
                colors = ButtonDefaults.primaryButtonColors(
                    backgroundColor = VidaColors.Emerald,
                    contentColor = VidaColors.Dark,
                ),
            ) { Text("Commencer") }
        } else {
            val total = DURATIONS[selectedIndex]
            val progress = if (total > 0) 1f - remaining.toFloat() / total else 0f
            Box(
                modifier = Modifier.size(95.dp),
                contentAlignment = Alignment.Center,
            ) {
                CircularProgressIndicator(
                    progress = progress,
                    modifier = Modifier.size(95.dp),
                    indicatorColor = VidaColors.Emerald,
                    trackColor = VidaColors.OnDark.copy(alpha = 0.15f),
                    strokeWidth = 6.dp,
                )
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "%d:%02d".format(remaining / 60, remaining % 60),
                        style = MaterialTheme.typography.title3,
                        color = VidaColors.OnDark,
                    )
                    Text(
                        text = "reste",
                        style = MaterialTheme.typography.caption3,
                        color = VidaColors.OnDark.copy(alpha = 0.5f),
                    )
                }
            }
            Spacer(modifier = Modifier.height(6.dp))
            Button(
                onClick = { isRunning = false },
                colors = ButtonDefaults.secondaryButtonColors(),
            ) { Text("Arrêter", style = MaterialTheme.typography.caption1) }
        }
    }
}

@Preview(widthDp = 192, heightDp = 192, showBackground = true, backgroundColor = 0xFF0A0A0F)
@Composable
fun RitualTimerPreview() {
    VidaWearTheme { RitualTimerScreen() }
}
