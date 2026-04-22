//
//  DashboardView.swift
//  VIDAWatch — P8-F3
//
//  Ecran principal : 3 anneaux concentriques (pas / mindful / calories) +
//  frequence cardiaque instantanee.
//

import SwiftUI

struct DashboardView: View {
    @Environment(StreakStore.self) private var streak
    let snapshot: HealthSnapshot

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                ProgressRing(value: snapshot.caloriesProgress, lineWidth: 5)
                    .padding(2)
                ProgressRing(value: snapshot.mindfulProgress, lineWidth: 5)
                    .padding(12)
                ProgressRing(
                    value: snapshot.stepsProgress,
                    lineWidth: 5,
                    iconSystemName: "figure.walk"
                )
                .padding(22)
            }
            .frame(width: 110, height: 110)

            VStack(spacing: 2) {
                HStack(spacing: 8) {
                    Label("\(snapshot.stepsToday)", systemImage: "figure.walk")
                    if let hr = snapshot.heartRateBpm {
                        Label("\(Int(hr))", systemImage: "heart.fill")
                            .foregroundStyle(VIDATheme.warmOrange)
                    }
                }
                .font(.caption2.weight(.medium))
                Label("🔥 \(streak.streak) j", systemImage: "")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(VIDATheme.emerald)
            }
        }
        .padding(.vertical, 4)
        .containerBackground(VIDATheme.emeraldSoft, for: .navigation)
    }
}

#Preview("Low") {
    DashboardView(snapshot: HealthSnapshot(
        stepsToday: 1_200,
        heartRateBpm: 68,
        mindfulMinutesToday: 2,
        activeCaloriesToday: 80,
        sleepHoursLastNight: 7.0
    ))
    .environment(StreakStore(client: SupabaseClient()))
}

#Preview("Achieved") {
    DashboardView(snapshot: HealthSnapshot(
        stepsToday: 9_500,
        heartRateBpm: 82,
        mindfulMinutesToday: 15,
        activeCaloriesToday: 450,
        sleepHoursLastNight: 7.5
    ))
    .environment({
        let s = StreakStore(client: SupabaseClient())
        s.applyRemoteUpdate(streak: 42, gratitudeStreak: 12)
        return s
    }())
}
