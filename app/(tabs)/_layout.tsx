import { Tabs } from 'expo-router'
import { View, Text } from 'react-native'
import { COLORS, TABS } from '../../lib/constants'

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: COLORS.background,
          borderTopColor: COLORS.border,
          borderTopWidth: 1,
          paddingTop: 6,
          paddingBottom: 10,
          height: 68,
        },
        tabBarActiveTintColor: COLORS.emerald,
        tabBarInactiveTintColor: COLORS.textMuted,
      }}
    >
      {TABS.map(t => (
        <Tabs.Screen
          key={t.name}
          name={t.name}
          options={{
            title: t.label,
            tabBarLabelStyle: { fontSize: 11, fontWeight: '500' },
            tabBarIcon: ({ color }) => (
              <View>
                <Text style={{ fontSize: 20, color }}>{t.emoji}</Text>
              </View>
            ),
          }}
        />
      ))}
    </Tabs>
  )
}
