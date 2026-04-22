//
//  VIDAWatchApp.swift
//  VIDAWatch — P8-F3
//
//  Composition root : injecte les stores + ContentView avec 6 ecrans.
//

import SwiftUI

@main
struct VIDAWatchApp: App {
    @State private var streakStore: StreakStore
    @State private var intentionStore: IntentionStore
    private let health: any HealthDataSource

    init() {
        let client = SupabaseClient()
        _streakStore = State(initialValue: StreakStore(client: client))
        _intentionStore = State(initialValue: IntentionStore(client: client))
        self.health = HealthKitManager()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(health: health)
                .environment(streakStore)
                .environment(intentionStore)
                .task {
                    await streakStore.refresh()
                    await intentionStore.refresh()
                }
        }
    }
}
