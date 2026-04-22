//
//  VIDAWatchApp.swift
//  VIDAWatch — P8-F2
//
//  Composition root : instancie les stores et les expose en @Environment
//  pour les ecrans F3.
//

import SwiftUI

@main
struct VIDAWatchApp: App {
    @State private var streakStore: StreakStore
    @State private var intentionStore: IntentionStore
    @State private var healthStore: HealthKitManager

    init() {
        let client = SupabaseClient()
        // @State init from let so init-order safe.
        _streakStore = State(initialValue: StreakStore(client: client))
        _intentionStore = State(initialValue: IntentionStore(client: client))
        _healthStore = State(initialValue: HealthKitManager())
    }

    var body: some Scene {
        WindowGroup {
            RootPlaceholderView()
                .environment(streakStore)
                .environment(intentionStore)
                .task {
                    // Premier refresh en background. Real UI F3.
                    _ = try? await healthStore.requestAuthorization()
                    await streakStore.refresh()
                    await intentionStore.refresh()
                }
        }
    }
}

// Placeholder visuel jusqu'a F3.
struct RootPlaceholderView: View {
    @Environment(StreakStore.self) private var streak
    @Environment(IntentionStore.self) private var intention

    var body: some View {
        VStack(spacing: 8) {
            Text("VIDA").font(.title3.weight(.light)).foregroundStyle(.tint)
            Text("🔥 \(streak.streak)").font(.caption)
            Text(intention.currentIntention)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding()
    }
}

#Preview {
    RootPlaceholderView()
        .environment(StreakStore(client: SupabaseClient()))
        .environment(IntentionStore(client: SupabaseClient()))
}
