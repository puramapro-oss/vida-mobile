//
//  ContentView.swift
//  VIDAWatch — P8-F3
//
//  TabView root : PageTabView pour la Digital Crown navigation entre les
//  6 ecrans.
//

import SwiftUI

struct ContentView: View {
    @State private var healthSnapshot: HealthSnapshot = .zero
    let health: any HealthDataSource

    var body: some View {
        TabView {
            DashboardView(snapshot: healthSnapshot).tag(0)
            StreakView().tag(1)
            IntentionView().tag(2)
            BreathView().tag(3)
            GratitudeView().tag(4)
            RitualTimerView().tag(5)
        }
        .tabViewStyle(.page)
        .task { await refreshHealth() }
    }

    private func refreshHealth() async {
        do {
            _ = try await health.requestAuthorization()
            let snap = try await health.currentSnapshot()
            self.healthSnapshot = snap
            // F4 : alimente les complications (steps / mindful).
            HealthComplicationSync.sync(from: snap)
        } catch {
            // On ignore les erreurs ici — l'UI montre .zero et le Dashboard
            // reste utilisable. Logging Sentry arrive post-SASU.
        }
    }
}

#Preview {
    ContentView(health: PreviewHealthDataSource())
        .environment(StreakStore(client: SupabaseClient()))
        .environment(IntentionStore(client: SupabaseClient()))
}

/// Mock preview-only pour eviter HealthKit en SwiftUI canvas.
final class PreviewHealthDataSource: HealthDataSource, @unchecked Sendable {
    func requestAuthorization() async throws -> Bool { true }
    func currentSnapshot() async throws -> HealthSnapshot {
        HealthSnapshot(
            stepsToday: 4_800,
            heartRateBpm: 74,
            mindfulMinutesToday: 6,
            activeCaloriesToday: 220,
            sleepHoursLastNight: 7.2
        )
    }
    func logMindfulSession(start: Date, end: Date) async throws {}
}
