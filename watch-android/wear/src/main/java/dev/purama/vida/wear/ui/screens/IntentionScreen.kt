package dev.purama.vida.wear.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import dev.purama.vida.wear.ui.theme.VidaColors
import dev.purama.vida.wear.ui.theme.VidaWearTheme

@Composable
fun IntentionScreen(
    intention: String,
    isLoading: Boolean,
    hasError: Boolean,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 12.dp, vertical = 16.dp)
            .verticalScroll(rememberScrollState()),
    ) {
        Text(
            text = "✨ Intention du jour",
            style = MaterialTheme.typography.caption2,
            color = VidaColors.Emerald,
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = intention,
            style = MaterialTheme.typography.body1,
            color = VidaColors.OnDark,
        )
        if (hasError) {
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Hors-ligne",
                style = MaterialTheme.typography.caption3,
                color = VidaColors.OnDark.copy(alpha = 0.5f),
            )
        }
    }
}

@Preview(widthDp = 192, heightDp = 192, showBackground = true, backgroundColor = 0xFF0A0A0F)
@Composable
fun IntentionPreview() {
    VidaWearTheme {
        IntentionScreen(
            intention = "Fais 3 minutes de respiration consciente avant ton prochain repas.",
            isLoading = false,
            hasError = false,
        )
    }
}
