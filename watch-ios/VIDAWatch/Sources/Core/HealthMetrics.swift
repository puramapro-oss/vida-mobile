//
//  HealthMetrics.swift
//  VIDAWatch — P8-F2
//
//  Value types decrivant l'etat sante capture par la montre.
//  Codable pour transiter via WatchConnectivity (F5) et Supabase.
//

import Foundation

public struct HealthSnapshot: Codable, Equatable, Sendable {
    public let stepsToday: Int
    public let heartRateBpm: Double?
    public let mindfulMinutesToday: Int
    public let activeCaloriesToday: Double
    public let sleepHoursLastNight: Double?
    public let capturedAt: Date

    public init(
        stepsToday: Int,
        heartRateBpm: Double?,
        mindfulMinutesToday: Int,
        activeCaloriesToday: Double,
        sleepHoursLastNight: Double?,
        capturedAt: Date = .init()
    ) {
        self.stepsToday = stepsToday
        self.heartRateBpm = heartRateBpm
        self.mindfulMinutesToday = mindfulMinutesToday
        self.activeCaloriesToday = activeCaloriesToday
        self.sleepHoursLastNight = sleepHoursLastNight
        self.capturedAt = capturedAt
    }

    /// Ring progressions 0.0 - 1.0 pour le Dashboard (F3).
    /// Objectifs par defaut bien-etre general ; surchargeables via Supabase
    /// profile plus tard.
    public var stepsProgress: Double {
        min(1.0, Double(stepsToday) / 8_000)
    }
    public var mindfulProgress: Double {
        min(1.0, Double(mindfulMinutesToday) / 10)
    }
    public var caloriesProgress: Double {
        min(1.0, activeCaloriesToday / 400)
    }

    public static let zero = HealthSnapshot(
        stepsToday: 0,
        heartRateBpm: nil,
        mindfulMinutesToday: 0,
        activeCaloriesToday: 0,
        sleepHoursLastNight: nil
    )
}
