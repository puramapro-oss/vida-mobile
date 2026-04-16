import { useEffect, useState } from 'react'
import { ScrollView, View, Text } from 'react-native'
import { SafeAreaView } from 'react-native-safe-area-context'
import { supabase } from '../../lib/supabase'
import { COLORS } from '../../lib/constants'

interface Impact {
  total_co2_saved_kg: number
  total_trees_funded: number
  total_water_protected_l: number
  total_waste_removed_g: number
  total_people_helped: number
  total_actions: number
}

export default function ImpactScreen() {
  const [impact, setImpact] = useState<Impact | null>(null)

  useEffect(() => {
    supabase.from('user_impact').select('*').maybeSingle().then(({ data }) => {
      setImpact(data as Impact | null)
    })
  }, [])

  const stats = [
    { label: 'CO₂ évité', value: impact?.total_co2_saved_kg ?? 0, unit: 'kg', emoji: '🌱' },
    { label: 'Arbres financés', value: impact?.total_trees_funded ?? 0, unit: '', emoji: '🌳' },
    { label: 'Eau protégée', value: impact?.total_water_protected_l ?? 0, unit: 'L', emoji: '💧' },
    { label: 'Déchets retirés', value: (impact?.total_waste_removed_g ?? 0) / 1000, unit: 'kg', emoji: '♻️' },
    { label: 'Personnes aidées', value: impact?.total_people_helped ?? 0, unit: '', emoji: '💛' },
    { label: 'Actions totales', value: impact?.total_actions ?? 0, unit: '', emoji: '✨' },
  ]

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.background }}>
      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 40 }}>
        <Text style={{ color: COLORS.textPrimary, fontSize: 28, fontWeight: '300', marginBottom: 4 }}>Ton empreinte</Text>
        <Text style={{ color: COLORS.textSecondary, fontSize: 14, marginBottom: 24 }}>
          Chaque action que tu poses laisse une trace. Voici la tienne.
        </Text>

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10 }}>
          {stats.map(s => (
            <View
              key={s.label}
              style={{
                minWidth: '47%',
                flex: 1,
                backgroundColor: 'rgba(255,255,255,0.04)',
                borderRadius: 20,
                padding: 16,
                borderWidth: 1,
                borderColor: COLORS.border,
              }}
            >
              <Text style={{ fontSize: 24, marginBottom: 6 }}>{s.emoji}</Text>
              <Text style={{ color: COLORS.textMuted, fontSize: 11, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 4 }}>
                {s.label}
              </Text>
              <Text style={{ color: COLORS.textPrimary, fontSize: 22, fontWeight: '600' }}>
                {typeof s.value === 'number' ? s.value.toFixed(s.unit === 'kg' || s.unit === 'L' ? 1 : 0) : s.value}
                {s.unit ? <Text style={{ fontSize: 12, color: COLORS.textSecondary }}> {s.unit}</Text> : null}
              </Text>
            </View>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  )
}
