import { useState } from 'react'
import { View, Text, TextInput, TouchableOpacity, ActivityIndicator, Alert } from 'react-native'
import { LinearGradient } from 'expo-linear-gradient'
import { useRouter } from 'expo-router'
import { supabase } from '../../lib/supabase'
import { COLORS } from '../../lib/constants'

export default function SignupScreen() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [fullName, setFullName] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSignup = async () => {
    if (!email || !password || password.length < 8) {
      Alert.alert('Manque', 'Email valide + mot de passe 8+ caractères.')
      return
    }
    setLoading(true)
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    })
    setLoading(false)
    if (error) {
      Alert.alert('Inscription impossible', error.message)
      return
    }
    Alert.alert('Bienvenue ✨', 'Ton compte est créé. Un email de confirmation t\'attend.')
    router.replace('/(auth)/login')
  }

  return (
    <View style={{ flex: 1, backgroundColor: COLORS.background, padding: 24, justifyContent: 'center' }}>
      <Text style={{ color: COLORS.textPrimary, fontSize: 34, fontWeight: '300', marginBottom: 8 }}>Rejoins VIDA.</Text>
      <Text style={{ color: COLORS.textSecondary, fontSize: 16, marginBottom: 32 }}>
        Un écosystème, un compte, des gestes qui comptent.
      </Text>

      <TextInput
        value={fullName}
        onChangeText={setFullName}
        placeholder="Ton prénom"
        placeholderTextColor={COLORS.textMuted}
        style={inputStyle}
      />
      <TextInput
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
        placeholder="toi@exemple.fr"
        placeholderTextColor={COLORS.textMuted}
        style={inputStyle}
      />
      <TextInput
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        placeholder="Mot de passe (8 caractères minimum)"
        placeholderTextColor={COLORS.textMuted}
        style={{ ...inputStyle, marginBottom: 24 }}
      />

      <TouchableOpacity onPress={handleSignup} disabled={loading} activeOpacity={0.85} style={{ borderRadius: 20, overflow: 'hidden', opacity: loading ? 0.6 : 1 }}>
        <LinearGradient colors={[COLORS.emerald, COLORS.sage]} start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }} style={{ padding: 16, alignItems: 'center' }}>
          {loading ? <ActivityIndicator color="white" /> : <Text style={{ color: 'white', fontSize: 16, fontWeight: '600' }}>Créer mon compte</Text>}
        </LinearGradient>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => router.replace('/(auth)/login')} style={{ marginTop: 24 }}>
        <Text style={{ color: COLORS.textSecondary, fontSize: 14, textAlign: 'center' }}>
          Déjà inscrit·e ? <Text style={{ color: COLORS.emerald, fontWeight: '600' }}>Se connecter</Text>
        </Text>
      </TouchableOpacity>
    </View>
  )
}

const inputStyle = {
  backgroundColor: 'rgba(255,255,255,0.04)',
  borderColor: COLORS.border,
  borderWidth: 1,
  borderRadius: 16,
  padding: 14,
  color: COLORS.textPrimary,
  marginBottom: 16,
} as const
