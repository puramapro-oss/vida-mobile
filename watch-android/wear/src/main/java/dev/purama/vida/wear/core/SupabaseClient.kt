package dev.purama.vida.wear.core

import android.content.Context
import android.content.SharedPreferences
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.nio.charset.StandardCharsets

/**
 * P8-F6 — Client REST Supabase minimal cote Wear OS. Miroir du
 * SupabaseClient.swift. Lit le JWT depuis un SharedPreferences commun avec
 * l'app phone via Wearable DataClient (F7) ou fallback EncryptedSharedPreferences.
 */
class SupabaseClient(
    private val context: Context,
    private val baseUrl: String = DEFAULT_BASE_URL,
    private val anonKey: String = DEFAULT_ANON_KEY,
) {
    private val prefs: SharedPreferences
        get() = context.getSharedPreferences(AUTH_PREFS, Context.MODE_PRIVATE)

    fun currentAccessToken(): String? = prefs.getString(TOKEN_KEY, null)

    fun setAccessToken(token: String?) {
        prefs.edit().apply {
            if (token == null) remove(TOKEN_KEY) else putString(TOKEN_KEY, token)
        }.apply()
    }

    suspend fun fetchProfile(): WatchProfile = withContext(Dispatchers.IO) {
        val token = currentAccessToken()
            ?: throw SupabaseException("Connecte-toi depuis le telephone puis ressaye.")
        val url = URL(
            "$baseUrl/rest/v1/profiles?select=streak,current_intention,gratitude_streak",
        )
        val conn = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "GET"
            setRequestProperty("apikey", anonKey)
            setRequestProperty("Authorization", "Bearer $token")
            setRequestProperty("Accept", "application/vnd.pgrst.object+json")
            setRequestProperty("Accept-Profile", SCHEMA)
            setRequestProperty("Content-Profile", SCHEMA)
            connectTimeout = 5_000
            readTimeout = 5_000
        }
        try {
            val code = conn.responseCode
            if (code !in 200..299) {
                val body = (conn.errorStream ?: conn.inputStream)
                    .bufferedReader(StandardCharsets.UTF_8).use { it.readText() }
                throw SupabaseException("HTTP $code: ${body.take(120)}")
            }
            val body = conn.inputStream
                .bufferedReader(StandardCharsets.UTF_8).use { it.readText() }
            val obj = JSONObject(body)
            WatchProfile(
                streak = obj.optInt("streak", 0),
                currentIntention = obj.optString("current_intention").ifBlank { null },
                gratitudeStreak = obj.optInt("gratitude_streak", 0),
            )
        } finally {
            conn.disconnect()
        }
    }

    suspend fun uploadHealthSnapshot(snapshot: HealthSnapshot) = withContext(Dispatchers.IO) {
        val token = currentAccessToken()
            ?: throw SupabaseException("Connecte-toi depuis le telephone puis ressaye.")
        val url = URL("$baseUrl/rest/v1/rpc/log_watch_snapshot")
        val conn = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            doOutput = true
            setRequestProperty("apikey", anonKey)
            setRequestProperty("Authorization", "Bearer $token")
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty("Accept-Profile", SCHEMA)
            setRequestProperty("Content-Profile", SCHEMA)
            connectTimeout = 5_000
            readTimeout = 5_000
        }
        val payload = JSONObject().apply {
            put("snapshot", JSONObject().apply {
                put("steps_today", snapshot.stepsToday)
                put("heart_rate_bpm", snapshot.heartRateBpm ?: JSONObject.NULL)
                put("mindful_minutes_today", snapshot.mindfulMinutesToday)
                put("active_calories_today", snapshot.activeCaloriesToday)
                put("sleep_hours_last_night", snapshot.sleepHoursLastNight ?: JSONObject.NULL)
                put("captured_at", snapshot.capturedAt)
            })
        }
        try {
            OutputStreamWriter(conn.outputStream, StandardCharsets.UTF_8).use {
                it.write(payload.toString())
            }
            val code = conn.responseCode
            if (code !in 200..299) throw SupabaseException("HTTP $code upload snapshot")
        } finally {
            conn.disconnect()
        }
    }

    companion object {
        const val DEFAULT_BASE_URL = "https://auth.purama.dev"
        const val DEFAULT_ANON_KEY =
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzQwNTI0ODAwLCJleHAiOjE4OTgyOTEyMDB9.GkiVoEuCykK7vIpNzY_Zmc6XPNnJF3BUPvijXXZy2aU"
        const val SCHEMA = "vida_sante"
        const val AUTH_PREFS = "vida.wear.auth"
        const val TOKEN_KEY = "supabase.access_token"
    }
}

class SupabaseException(message: String) : RuntimeException(message)
