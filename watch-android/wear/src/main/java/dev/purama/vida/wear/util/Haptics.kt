package dev.purama.vida.wear.util

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * P8-F6 — Helpers vibration compatibles API 30+.
 */
private fun vibrator(context: Context): Vibrator? {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
        manager?.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    }
}

fun vibrateSuccess(context: Context) {
    vibrator(context)?.vibrate(VibrationEffect.createOneShot(40, VibrationEffect.DEFAULT_AMPLITUDE))
}

fun vibrateClick(context: Context) {
    vibrator(context)?.vibrate(VibrationEffect.createOneShot(20, VibrationEffect.DEFAULT_AMPLITUDE))
}

fun vibrateStart(context: Context) {
    vibrator(context)?.vibrate(
        VibrationEffect.createWaveform(longArrayOf(0, 30, 50, 30), -1),
    )
}
