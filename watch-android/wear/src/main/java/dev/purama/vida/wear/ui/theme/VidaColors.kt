package dev.purama.vida.wear.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.wear.compose.material.Colors
import androidx.wear.compose.material.MaterialTheme

object VidaColors {
    val Emerald = Color(0xFF10B981)
    val EmeraldSoft = Color(0xFF10B981).copy(alpha = 0.18f)
    val Gold = Color(0xFFFFD700)
    val WarmOrange = Color(0xFFFA9447)
    val DeepViolet = Color(0xFF7C3AED)
    val OnDark = Color(0xFFF5F5F5)
    val Dark = Color(0xFF0A0A0F)
}

val VidaColorScheme = Colors(
    primary = VidaColors.Emerald,
    primaryVariant = VidaColors.DeepViolet,
    secondary = VidaColors.WarmOrange,
    secondaryVariant = VidaColors.Gold,
    background = VidaColors.Dark,
    surface = VidaColors.Dark,
    error = Color(0xFFEF4444),
    onPrimary = VidaColors.Dark,
    onSecondary = VidaColors.Dark,
    onBackground = VidaColors.OnDark,
    onSurface = VidaColors.OnDark,
    onError = VidaColors.OnDark,
)

@Composable
fun VidaWearTheme(content: @Composable () -> Unit) {
    MaterialTheme(colors = VidaColorScheme, content = content)
}

fun progressBrush(value: Double): Brush {
    val stops = if (value >= 1.0) {
        arrayOf(0f to VidaColors.Gold, 1f to VidaColors.WarmOrange)
    } else {
        arrayOf(0f to VidaColors.Emerald, 1f to VidaColors.DeepViolet)
    }
    return Brush.linearGradient(colorStops = stops)
}
