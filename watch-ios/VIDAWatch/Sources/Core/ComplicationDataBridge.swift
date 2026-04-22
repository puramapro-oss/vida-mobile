//
//  ComplicationDataBridge.swift
//  VIDAWatchComplication — P8-F4
//
//  Pont de donnees entre l'app (qui ecrit le dernier etat dans App Group
//  UserDefaults) et les complications (qui lisent + construisent leur timeline).
//  Fallback silencieux sur .standard si App Group pas encore active.
//

import Foundation

public struct ComplicationSnapshot: Codable, Equatable, Sendable {
    public let streak: Int
    public let gratitudeStreak: Int
    public let stepsToday: Int
    public let stepsGoal: Int
    public let mindfulMinutesToday: Int
    public let updatedAt: Date

    public init(
        streak: Int = 0,
        gratitudeStreak: Int = 0,
        stepsToday: Int = 0,
        stepsGoal: Int = 8_000,
        mindfulMinutesToday: Int = 0,
        updatedAt: Date = .init()
    ) {
        self.streak = streak
        self.gratitudeStreak = gratitudeStreak
        self.stepsToday = stepsToday
        self.stepsGoal = max(1, stepsGoal)
        self.mindfulMinutesToday = mindfulMinutesToday
        self.updatedAt = updatedAt
    }

    public var stepsProgress: Double {
        min(1.0, Double(stepsToday) / Double(stepsGoal))
    }

    public static let zero = ComplicationSnapshot()
}

public enum ComplicationDataBridge {
    public static let appGroupSuite = "group.dev.purama.vida"
    public static let storageKey = "vida.complication.snapshot"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupSuite) ?? .standard
    }

    public static func read() -> ComplicationSnapshot {
        guard let data = defaults.data(forKey: storageKey) else { return .zero }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(ComplicationSnapshot.self, from: data)) ?? .zero
    }

    @discardableResult
    public static func write(_ snapshot: ComplicationSnapshot) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return false }
        defaults.set(data, forKey: storageKey)
        return true
    }
}
