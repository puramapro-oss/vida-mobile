//
//  StreakView.swift
//  VIDAWatch — P8-F3
//

import SwiftUI
import WatchKit

struct StreakView: View {
    @Environment(StreakStore.self) private var streak

    var body: some View {
        VStack(spacing: 8) {
            Text("🔥")
                .font(.system(size: 44))
                .scaleEffect(streak.streak > 0 ? 1.0 : 0.8)
                .animation(.spring(duration: 0.6), value: streak.streak)
            Text("\(streak.streak) jour\(streak.streak > 1 ? "s" : "")")
                .font(.title3.monospacedDigit())
                .foregroundStyle(VIDATheme.warmOrange)
            Text("de suite")
                .font(.caption2)
                .foregroundStyle(.secondary)
            if streak.gratitudeStreak > 0 {
                Label("\(streak.gratitudeStreak) gratitudes", systemImage: "heart.text.square.fill")
                    .font(.caption2)
                    .foregroundStyle(VIDATheme.emerald)
                    .padding(.top, 2)
            }
        }
        .padding()
        .onAppear { playHapticIfStreak() }
        .containerBackground(VIDATheme.emeraldSoft, for: .navigation)
    }

    private func playHapticIfStreak() {
        guard streak.streak > 0 else { return }
        WKInterfaceDevice.current().play(.success)
    }
}

#Preview("7j") {
    StreakView()
        .environment({
            let s = StreakStore(client: SupabaseClient())
            s.applyRemoteUpdate(streak: 7, gratitudeStreak: 3)
            return s
        }())
}

#Preview("Zero") {
    StreakView()
        .environment(StreakStore(client: SupabaseClient()))
}
