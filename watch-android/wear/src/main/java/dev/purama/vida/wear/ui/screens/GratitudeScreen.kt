package dev.purama.vida.wear.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
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
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import dev.purama.vida.wear.ui.theme.VidaColors
import dev.purama.vida.wear.ui.theme.VidaWearTheme
import dev.purama.vida.wear.util.vibrateSuccess

@Composable
fun GratitudeScreen(
    gratitudeStreak: Int,
    onSave: (String) -> Unit,
) {
    val context = LocalContext.current
    var captured by remember { mutableStateOf<String?>(null) }

    val prompts = remember {
        listOf(
            "Mon corps m'a permis de…",
            "J'ai souri quand…",
            "Quelqu'un m'a offert…",
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(10.dp)
            .verticalScroll(rememberScrollState()),
    ) {
        Text(
            text = "💜 Gratitude",
            style = MaterialTheme.typography.caption1,
            color = VidaColors.Emerald,
        )
        Spacer(modifier = Modifier.height(4.dp))
        if (captured != null) {
            Text(
                text = "✓ \"${captured}\"",
                style = MaterialTheme.typography.caption2,
                color = VidaColors.Emerald,
            )
        } else {
            Text(
                text = "Prends 10 secondes.",
                style = MaterialTheme.typography.caption2,
                color = VidaColors.OnDark.copy(alpha = 0.65f),
            )
            Spacer(modifier = Modifier.height(4.dp))
            prompts.forEach { prompt ->
                Chip(
                    onClick = {
                        captured = prompt
                        vibrateSuccess(context)
                        onSave(prompt)
                    },
                    colors = ChipDefaults.secondaryChipColors(),
                    modifier = Modifier.fillMaxWidth(),
                    label = {
                        Text(
                            text = prompt,
                            style = MaterialTheme.typography.caption3,
                        )
                    },
                )
                Spacer(modifier = Modifier.height(2.dp))
            }
            Spacer(modifier = Modifier.height(2.dp))
            Button(
                onClick = {
                    captured = "Gratitude captee 🙏"
                    vibrateSuccess(context)
                    onSave("Gratitude captee 🙏")
                },
                colors = ButtonDefaults.primaryButtonColors(
                    backgroundColor = VidaColors.WarmOrange,
                    contentColor = VidaColors.Dark,
                ),
            ) {
                Text("Dicter (phone)")
            }
        }
        if (gratitudeStreak > 0) {
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = "🔥 $gratitudeStreak jours",
                style = MaterialTheme.typography.caption2,
                color = VidaColors.WarmOrange,
            )
        }
    }
}

@Preview(widthDp = 192, heightDp = 192, showBackground = true, backgroundColor = 0xFF0A0A0F)
@Composable
fun GratitudePreview() {
    VidaWearTheme {
        GratitudeScreen(gratitudeStreak = 5, onSave = {})
    }
}
