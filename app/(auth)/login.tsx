import { useState } from 'react'
import { View, Text, TextInput, TouchableOpacity, ActivityIndicator, Alert, Platform } from 'react-native'
import { LinearGradient } from 'expo-linear-gradient'
import { useRouter } from 'expo-router'
import { supabase } from '../../lib/supabase'
import { COLORS } from '../../lib/constants'

export default function LoginScreen() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Manque', 'Email et mot de passe requis.')
      return
    }
    setLoading(true)
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    setLoading(false)
    if (error) {
      Alert.alert('Connexion impossible', error.message === 'Invalid login credentials' ? 'Identifiants invalides.' : error.message)
      return
    }
    router.replace('/(tabs)/home')
  }

  return (
    <View style={{ flex: 1, backgroundColor: COLORS.background, padding: 24, justifyContent: 'center' }}>
      <Text style={{ color: COLORS.textPrimary, fontSize: 34, fontWeight: '300', marginBottom: 8 }}>Bienvenue.</Text>
      <Text style={{ color: COLORS.textSecondary, fontSize: 16, marginBottom: 32 }}>
        L'écosystème vivant qui transforme chaque action en impact réel.
      </Text>

      <Text style={{ color: COLORS.textSecondary, fontSize: 12, marginBottom: 6, textTransform: 'uppercase', letterSpacing: 1 }}>
        Email
      </Text>
      <TextInput
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
        placeholder="toi@exemple.fr"
        placeholderTextColor={COLORS.textMuted}
        style={{
          backgroundColor: 'rgba(255,255,255,0.04)',
          borderColor: COLORS.border,
          borderWidth: 1,
          borderRadius: 16,
          padding: 14,
          color: COLORS.textPrimary,
          marginBottom: 16,
        }}
      />

      <Text style={{ color: COLORS.textSecondary, fontSize: 12, marginBottom: 6, textTransform: 'uppercase', letterSpacing: 1 }}>
        Mot de passe
      </Text>
      <TextInput
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        placeholder="••••••••"
        placeholderTextColor={COLORS.textMuted}
        style={{
          backgroundColor: 'rgba(255,255,255,0.04)',
          borderColor: COLORS.border,
          borderWidth: 1,
          borderRadius: 16,
          padding: 14,
          color: COLORS.textPrimary,
          marginBottom: 24,
        }}
      />

      <TouchableOpacity
        onPress={handleLogin}
        disabled={loading}
        activeOpacity={0.85}
        style={{ borderRadius: 20, overflow: 'hidden', opacity: loading ? 0.6 : 1 }}
      >
        <LinearGradient
          colors={[COLORS.emerald, COLORS.sage]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={{ padding: 16, alignItems: 'center' }}
        >
          {loading ? (
            <ActivityIndicator color="white" />
          ) : (
            <Text style={{ color: 'white', fontSize: 16, fontWeight: '600' }}>Entrer dans VIDA</Text>
          )}
        </LinearGradient>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => router.push('/(auth)/signup' as never)} style={{ marginTop: 24 }}>
        <Text style={{ color: COLORS.textSecondary, fontSize: 14, textAlign: 'center' }}>
          Pas encore de compte ? <Text style={{ color: COLORS.emerald, fontWeight: '600' }}>Rejoins l'écosystème</Text>
        </Text>
      </TouchableOpacity>

      {Platform.OS !== 'web' && (
        <Text style={{ color: COLORS.textMuted, fontSize: 11, textAlign: 'center', marginTop: 32 }}>
          iOS & Android — session 30 jours, chiffrée via SecureStore.
        </Text>
      )}
    </View>
  )
}
