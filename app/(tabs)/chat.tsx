import { useState, useRef } from 'react'
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
} from 'react-native'
import { SafeAreaView } from 'react-native-safe-area-context'
import { LinearGradient } from 'expo-linear-gradient'
import { supabase } from '../../lib/supabase'
import { COLORS, WEB_URL } from '../../lib/constants'

interface Msg {
  role: 'user' | 'assistant'
  content: string
}

export default function ChatScreen() {
  const [messages, setMessages] = useState<Msg[]>([
    {
      role: 'assistant',
      content: 'Je suis VIDA. Raconte-moi ta journée, pose-moi une question, partage ce qui bouge en toi ✨',
    },
  ])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const scrollRef = useRef<ScrollView>(null)

  const send = async () => {
    if (!input.trim() || loading) return
    const userMsg: Msg = { role: 'user', content: input.trim() }
    setMessages(m => [...m, userMsg])
    setInput('')
    setLoading(true)
    try {
      const { data: { session } } = await supabase.auth.getSession()
      const res = await fetch(`${WEB_URL}/api/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(session ? { Authorization: `Bearer ${session.access_token}` } : {}),
        },
        body: JSON.stringify({ messages: [...messages, userMsg], stream: false }),
      })
      const data = await res.json()
      const reply = (data?.content as string) ?? data?.message ?? 'Je reviens dans un instant.'
      setMessages(m => [...m, { role: 'assistant', content: reply }])
    } catch {
      setMessages(m => [...m, { role: 'assistant', content: 'Connexion instable. Réessaie dans un instant.' }])
    } finally {
      setLoading(false)
      setTimeout(() => scrollRef.current?.scrollToEnd({ animated: true }), 100)
    }
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.background }}>
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <View style={{ padding: 16, borderBottomWidth: 1, borderBottomColor: COLORS.border }}>
          <Text style={{ color: COLORS.textPrimary, fontSize: 18, fontWeight: '500' }}>VIDA</Text>
          <Text style={{ color: COLORS.textMuted, fontSize: 11 }}>Ta présence vivante</Text>
        </View>

        <ScrollView
          ref={scrollRef}
          contentContainerStyle={{ padding: 16, gap: 10 }}
          onContentSizeChange={() => scrollRef.current?.scrollToEnd({ animated: true })}
        >
          {messages.map((m, i) => (
            <View
              key={i}
              style={{
                alignSelf: m.role === 'user' ? 'flex-end' : 'flex-start',
                maxWidth: '86%',
              }}
            >
              {m.role === 'user' ? (
                <LinearGradient
                  colors={[COLORS.emerald, COLORS.sage]}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={{ borderRadius: 20, padding: 12, borderBottomRightRadius: 6 }}
                >
                  <Text style={{ color: 'white', fontSize: 15 }}>{m.content}</Text>
                </LinearGradient>
              ) : (
                <View
                  style={{
                    backgroundColor: 'rgba(255,255,255,0.04)',
                    borderRadius: 20,
                    padding: 12,
                    borderBottomLeftRadius: 6,
                    borderWidth: 1,
                    borderColor: COLORS.border,
                  }}
                >
                  <Text style={{ color: COLORS.textPrimary, fontSize: 15, lineHeight: 22 }}>{m.content}</Text>
                </View>
              )}
            </View>
          ))}
          {loading ? (
            <View style={{ padding: 12 }}>
              <ActivityIndicator color={COLORS.emerald} size="small" />
            </View>
          ) : null}
        </ScrollView>

        <View style={{ flexDirection: 'row', gap: 8, padding: 12, borderTopWidth: 1, borderTopColor: COLORS.border }}>
          <TextInput
            value={input}
            onChangeText={setInput}
            placeholder="Pose ta question…"
            placeholderTextColor={COLORS.textMuted}
            multiline
            style={{
              flex: 1,
              backgroundColor: 'rgba(255,255,255,0.04)',
              borderRadius: 20,
              paddingHorizontal: 16,
              paddingVertical: 10,
              color: COLORS.textPrimary,
              maxHeight: 100,
              borderWidth: 1,
              borderColor: COLORS.border,
            }}
          />
          <TouchableOpacity
            onPress={send}
            disabled={!input.trim() || loading}
            style={{ opacity: !input.trim() || loading ? 0.4 : 1, justifyContent: 'center' }}
          >
            <LinearGradient
              colors={[COLORS.emerald, COLORS.sage]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{ width: 44, height: 44, borderRadius: 22, alignItems: 'center', justifyContent: 'center' }}
            >
              <Text style={{ color: 'white', fontSize: 18 }}>↑</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  )
}
