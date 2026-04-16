import { useEffect, useState } from 'react'
import { View, Text, TouchableOpacity, Alert, Linking, ScrollView } from 'react-native'
import { SafeAreaView } from 'react-native-safe-area-context'
import { supabase } from '../../lib/supabase'
import { COLORS, WEB_URL } from '../../lib/constants'

interface Profile {
  full_name: string | null
  email: string | null
  plan: string | null
}

export default function ProfileScreen() {
  const [profile, setProfile] = useState<Profile | null>(null)

  useEffect(() => {
    (async () => {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return
      const { data } = await supabase
        .from('profiles')
        .select('full_name, email, plan')
        .eq('id', user.id)
        .maybeSingle()
      setProfile(data as Profile | null)
    })()
  }, [])

  const handleLogout = async () => {
    Alert.alert('Se déconnecter', 'Confirmer ?', [
      { text: 'Annuler', style: 'cancel' },
      {
        text: 'Oui',
        style: 'destructive',
        onPress: async () => {
          await supabase.auth.signOut()
        },
      },
    ])
  }

  const handleSubscribe = async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return
    Linking.openURL(`${WEB_URL}/subscribe?app=vida&user=${user.id}&return=purama://activate`)
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.background }}>
      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 40 }}>
        <Text style={{ color: COLORS.textPrimary, fontSize: 28, fontWeight: '300', marginBottom: 24 }}>Mon compte</Text>

        <View
          style={{
            backgroundColor: 'rgba(255,255,255,0.04)',
            borderRadius: 24,
            padding: 20,
            borderWidth: 1,
            borderColor: COLORS.border,
            marginBottom: 16,
          }}
        >
          <Text style={{ color: COLORS.textMuted, fontSize: 11, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 6 }}>Nom</Text>
          <Text style={{ color: COLORS.textPrimary, fontSize: 17, fontWeight: '500', marginBottom: 16 }}>
            {profile?.full_name ?? 'Belle âme'}
          </Text>
          <Text style={{ color: COLORS.textMuted, fontSize: 11, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 6 }}>Email</Text>
          <Text style={{ color: COLORS.textSecondary, fontSize: 15, marginBottom: 16 }}>{profile?.email ?? '—'}</Text>
          <Text style={{ color: COLORS.textMuted, fontSize: 11, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 6 }}>Plan</Text>
          <Text style={{ color: COLORS.emerald, fontSize: 15, fontWeight: '600' }}>
            {profile?.plan === 'premium' ? 'Premium — actif' : 'Découverte'}
          </Text>
        </View>

        {profile?.plan !== 'premium' && (
          <TouchableOpacity
            onPress={handleSubscribe}
            style={{
              backgroundColor: COLORS.emerald,
              borderRadius: 20,
              padding: 16,
              alignItems: 'center',
              marginBottom: 12,
            }}
          >
            <Text style={{ color: '#052e16', fontSize: 15, fontWeight: '600' }}>Débloquer mes gains</Text>
          </TouchableOpacity>
        )}

        <TouchableOpacity
          onPress={() => Linking.openURL(`${WEB_URL}/dashboard/settings`)}
          style={{
            backgroundColor: 'rgba(255,255,255,0.04)',
            borderRadius: 20,
            padding: 16,
            alignItems: 'center',
            marginBottom: 12,
            borderWidth: 1,
            borderColor: COLORS.border,
          }}
        >
          <Text style={{ color: COLORS.textPrimary, fontSize: 15 }}>Paramètres complets</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={handleLogout}
          style={{
            backgroundColor: 'rgba(255,255,255,0.02)',
            borderRadius: 20,
            padding: 16,
            alignItems: 'center',
            borderWidth: 1,
            borderColor: 'rgba(239,68,68,0.3)',
          }}
        >
          <Text style={{ color: '#EF4444', fontSize: 15 }}>Se déconnecter</Text>
        </TouchableOpacity>

        <Text style={{ color: COLORS.textMuted, fontSize: 11, textAlign: 'center', marginTop: 24 }}>
          VIDA · dev.purama.vida · v0.1.0
        </Text>
      </ScrollView>
    </SafeAreaView>
  )
}
