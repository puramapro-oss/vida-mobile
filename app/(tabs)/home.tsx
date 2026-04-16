import { useEffect, useState } from 'react'
import { ScrollView, View, Text, RefreshControl } from 'react-native'
import { SafeAreaView } from 'react-native-safe-area-context'
import { LinearGradient } from 'expo-linear-gradient'
import { supabase } from '../../lib/supabase'
import { COLORS } from '../../lib/constants'

interface Stats {
  xp: number
  graines: number
  streak: number
  walletBalance: number
}

export default function HomeScreen() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [name, setName] = useState<string>('')
  const [affirmation, setAffirmation] = useState<string>('')
  const [refreshing, setRefreshing] = useState(false)

  const load = async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return
    const { data: profile } = await supabase
      .from('profiles')
      .select('full_name, xp, purama_points, streak, wallet_balance')
      .eq('id', user.id)
      .maybeSingle()
    if (profile) {
      setName((profile.full_name as string | null) ?? 'belle âme')
      setStats({
        xp: (profile.xp as number) ?? 0,
        graines: (profile.purama_points as number) ?? 0,
        streak: (profile.streak as number) ?? 0,
        walletBalance: (profile.wallet_balance as number) ?? 0,
      })
    }
    const { data: aff } = await supabase
      .from('affirmations')
      .select('text_fr')
      .limit(50)
    if (aff && aff.length > 0) {
      const pick = aff[Math.floor(Math.random() * aff.length)]
      setAffirmation((pick?.text_fr as string) ?? '')
    }
  }

  useEffect(() => { load() }, [])

  const onRefresh = async () => {
    setRefreshing(true)
    await load()
    setRefreshing(false)
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.background }}>
      <ScrollView
        contentContainerStyle={{ padding: 20, paddingBottom: 40 }}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={COLORS.emerald} />}
      >
        <Text style={{ color: COLORS.textSecondary, fontSize: 13, marginBottom: 4 }}>Bonjour,</Text>
        <Text style={{ color: COLORS.textPrimary, fontSize: 28, fontWeight: '300', marginBottom: 24 }}>{name}</Text>

        {affirmation ? (
          <LinearGradient
            colors={['rgba(16,185,129,0.15)', 'rgba(132,204,22,0.05)']}
            style={{ borderRadius: 24, padding: 20, marginBottom: 24, borderWidth: 1, borderColor: 'rgba(16,185,129,0.2)' }}
          >
            <Text style={{ color: COLORS.emerald, fontSize: 11, textTransform: 'uppercase', letterSpacing: 1.5, marginBottom: 8 }}>
              Affirmation du jour
            </Text>
            <Text style={{ color: COLORS.textPrimary, fontSize: 17, lineHeight: 24, fontStyle: 'italic' }}>« {affirmation} »</Text>
          </LinearGradient>
        ) : null}

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10 }}>
          <StatCard label="XP" value={stats?.xp ?? 0} />
          <StatCard label="Graines" value={stats?.graines ?? 0} />
          <StatCard label="Streak" value={stats?.streak ?? 0} suffix={stats?.streak ? ' j' : ''} />
          <StatCard label="Wallet" value={stats?.walletBalance ?? 0} suffix=" €" />
        </View>

        <Text style={{ color: COLORS.textPrimary, fontSize: 18, fontWeight: '500', marginTop: 32, marginBottom: 12 }}>
          Ton action du jour
        </Text>
        <View
          style={{
            backgroundColor: 'rgba(255,255,255,0.04)',
            borderRadius: 24,
            padding: 20,
            borderWidth: 1,
            borderColor: COLORS.border,
          }}
        >
          <Text style={{ color: COLORS.textPrimary, fontSize: 16, fontWeight: '500', marginBottom: 6 }}>
            Respire 4-7-8 pendant 3 cycles
          </Text>
          <Text style={{ color: COLORS.textSecondary, fontSize: 14, lineHeight: 20 }}>
            2 minutes. Gratuit. Le système nerveux te remerciera.
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  )
}

function StatCard({ label, value, suffix }: { label: string; value: number; suffix?: string }) {
  return (
    <View
      style={{
        flex: 1,
        minWidth: '47%',
        backgroundColor: 'rgba(255,255,255,0.04)',
        borderRadius: 20,
        padding: 16,
        borderWidth: 1,
        borderColor: COLORS.border,
      }}
    >
      <Text style={{ color: COLORS.textMuted, fontSize: 11, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 6 }}>
        {label}
      </Text>
      <Text style={{ color: COLORS.textPrimary, fontSize: 24, fontWeight: '600' }}>
        {value.toLocaleString('fr-FR')}
        {suffix ? <Text style={{ fontSize: 14, color: COLORS.textSecondary }}>{suffix}</Text> : null}
      </Text>
    </View>
  )
}
