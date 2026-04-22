//
//  StreakStore.swift
//  VIDAWatch — P8-F2/F4
//
//  Observable store pour le streak + le streak gratitude.
//  F4 : chaque mise a jour synchronise la ComplicationSnapshot et reload
//  les timelines via WidgetCenter.
//

import Foundation
import Observation
import WidgetKit

@MainActor
@Observable
public final class StreakStore {
    public private(set) var streak: Int = 0
    public private(set) var gratitudeStreak: Int = 0
    public private(set) var lastRefreshedAt: Date?
    public private(set) var isLoading: Bool = false
    public private(set) var lastError: String?

    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func refresh() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            let profile = try await client.fetchProfile()
            self.streak = profile.streak
            self.gratitudeStreak = profile.gratitudeStreak
            self.lastRefreshedAt = Date()
            syncComplication()
        } catch {
            self.lastError = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
        }
    }

    // Updates optimistes utilises par WatchConnectivity en F5.
    public func applyRemoteUpdate(streak: Int, gratitudeStreak: Int) {
        self.streak = streak
        self.gratitudeStreak = gratitudeStreak
        self.lastRefreshedAt = Date()
        syncComplication()
    }

    /// F4 : propage la derniere valeur aux complications.
    private func syncComplication() {
        let previous = ComplicationDataBridge.read()
        let next = ComplicationSnapshot(
            streak: streak,
            gratitudeStreak: gratitudeStreak,
            stepsToday: previous.stepsToday,
            stepsGoal: previous.stepsGoal,
            mindfulMinutesToday: previous.mindfulMinutesToday,
            updatedAt: Date()
        )
        ComplicationDataBridge.write(next)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
