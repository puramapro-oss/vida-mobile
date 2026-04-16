import { useEffect, useState } from 'react'
import { FlatList, View, Text, TouchableOpacity } from 'react-native'
import { SafeAreaView } from 'react-native-safe-area-context'
import { supabase } from '../../lib/supabase'
import { COLORS } from '../../lib/constants'

interface Mission {
  id: string
  title: string
  description: string | null
  category: string | null
  reward_amount: number | null
  reward_type: string | null
}

export default function MissionsScreen() {
  const [missions, setMissions] = useState<Mission[]>([])
  const [filter, setFilter] = useState<'all' | 'paid' | 'ecology' | 'health' | 'community'>('all')

  useEffect(() => {
    supabase
      .from('missions')
      .select('id, title, description, category, reward_amount, reward_type')
      .eq('active', true)
      .limit(30)
      .then(({ data }) => setMissions((data ?? []) as Mission[]))
  }, [])

  const filtered = missions.filter(m => {
    if (filter === 'all') return true
    if (filter === 'paid') return m.reward_type === 'euros'
    return m.category === filter
  })

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: COLORS.background }}>
      <View style={{ padding: 20, paddingBottom: 12 }}>
        <Text style={{ color: COLORS.textPrimary, fontSize: 28, fontWeight: '300', marginBottom: 4 }}>Missions</Text>
        <Text style={{ color: COLORS.textSecondary, fontSize: 14 }}>Chaque action compte.</Text>
      </View>

      <View style={{ flexDirection: 'row', gap: 8, paddingHorizontal: 20, paddingBottom: 12 }}>
        {(['all', 'paid', 'ecology', 'health', 'community'] as const).map(f => (
          <TouchableOpacity
            key={f}
            onPress={() => setFilter(f)}
            style={{
              paddingHorizontal: 12,
              paddingVertical: 6,
              borderRadius: 999,
              backgroundColor: filter === f ? COLORS.emerald : 'rgba(255,255,255,0.04)',
              borderWidth: 1,
              borderColor: filter === f ? COLORS.emerald : COLORS.border,
            }}
          >
            <Text style={{ color: filter === f ? '#052e16' : COLORS.textSecondary, fontSize: 12, fontWeight: '500' }}>
              {f === 'all' ? 'Tout' : f === 'paid' ? 'Rémunérées' : f}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <FlatList
        data={filtered}
        keyExtractor={m => m.id}
        contentContainerStyle={{ padding: 20, gap: 10 }}
        ListEmptyComponent={
          <Text style={{ color: COLORS.textMuted, textAlign: 'center', marginTop: 40 }}>
            Aucune mission dans cette catégorie.
          </Text>
        }
        renderItem={({ item }) => (
          <View
            style={{
              backgroundColor: 'rgba(255,255,255,0.04)',
              borderRadius: 20,
              padding: 16,
              borderWidth: 1,
              borderColor: COLORS.border,
            }}
          >
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 }}>
              <Text style={{ color: COLORS.textPrimary, fontSize: 15, fontWeight: '600', flex: 1 }}>{item.title}</Text>
              {item.reward_amount ? (
                <View style={{ backgroundColor: 'rgba(16,185,129,0.15)', borderRadius: 999, paddingHorizontal: 8, paddingVertical: 3, marginLeft: 8 }}>
                  <Text style={{ color: COLORS.emerald, fontSize: 11, fontWeight: '600' }}>
                    {item.reward_type === 'euros' ? `+${item.reward_amount}€` : `+${item.reward_amount} pts`}
                  </Text>
                </View>
              ) : null}
            </View>
            {item.description ? (
              <Text style={{ color: COLORS.textSecondary, fontSize: 13, lineHeight: 18 }}>{item.description}</Text>
            ) : null}
          </View>
        )}
      />
    </SafeAreaView>
  )
}
