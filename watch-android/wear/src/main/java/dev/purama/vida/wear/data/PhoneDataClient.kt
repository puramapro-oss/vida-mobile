package dev.purama.vida.wear.data

import android.content.Context
import android.util.Log
import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import dev.purama.vida.wear.stores.IntentionStore
import dev.purama.vida.wear.stores.StreakStore

/**
 * P8-F7 — Pont Wearable Data Layer pour le watch Wear OS.
 * Envoie des WearMessage vers le phone paire et recoit via OnMessageReceivedListener.
 */
class PhoneDataClient(
    private val context: Context,
    private val streakStore: StreakStore? = null,
    private val intentionStore: IntentionStore? = null,
) {
    private val client: MessageClient = Wearable.getMessageClient(context)

    private val listener = MessageClient.OnMessageReceivedListener { event: MessageEvent ->
        if (event.path != WEAR_MESSAGE_PATH) return@OnMessageReceivedListener
        val raw = String(event.data, Charsets.UTF_8)
        val msg = WearMessage.decode(raw) ?: return@OnMessageReceivedListener
        applyIncoming(msg)
    }

    fun start() {
        client.addListener(listener)
    }

    fun stop() {
        client.removeListener(listener)
    }

    /**
     * Envoi broadcast vers tous les nodes connectes (phone paire).
     * Fire-and-forget : les echecs sont logs mais pas remontes a l'UI.
     */
    fun send(message: WearMessage) {
        val bytes = message.encode().toByteArray(Charsets.UTF_8)
        val nodeClient = Wearable.getNodeClient(context)
        nodeClient.connectedNodes
            .addOnSuccessListener { nodes ->
                for (node in nodes) {
                    client.sendMessage(node.id, WEAR_MESSAGE_PATH, bytes)
                        .addOnFailureListener { e ->
                            Log.w("VidaWear", "sendMessage failed to ${node.id}", e)
                        }
                }
            }
            .addOnFailureListener { e -> Log.w("VidaWear", "connectedNodes failed", e) }
    }

    private fun applyIncoming(message: WearMessage) {
        when (message) {
            is WearMessage.StreakUpdate ->
                streakStore?.applyRemoteUpdate(message.streak, message.gratitudeStreak)
            is WearMessage.IntentionUpdate ->
                intentionStore?.applyRemoteUpdate(message.text)
            is WearMessage.AuthTokenUpdate -> persistToken(message.token)
            is WearMessage.RitualStarted, is WearMessage.RitualCompleted -> {
                // Hooks UI a venir.
            }
            is WearMessage.GratitudeCapture,
            is WearMessage.HealthSnapshotPush,
            WearMessage.SyncRequest -> {
                // Messages sortants cote watch ; si on les recoit ici on ignore.
            }
        }
    }

    private fun persistToken(token: String) {
        val prefs = context.getSharedPreferences("vida.wear.auth", Context.MODE_PRIVATE)
        prefs.edit().putString("supabase.access_token", token).apply()
    }
}
