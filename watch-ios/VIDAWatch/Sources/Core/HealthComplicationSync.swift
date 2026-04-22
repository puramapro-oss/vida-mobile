//
//  HealthComplicationSync.swift
//  VIDAWatch — P8-F4
//
//  Helper dedie : quand le Dashboard recupere un nouveau HealthSnapshot, on
//  ecrit les champs steps/mindful dans la ComplicationSnapshot (merge avec
//  le streak deja ecrit) + reload timelines.
//

import Foundation
import WidgetKit

@MainActor
public enum HealthComplicationSync {
    public static func sync(from snapshot: HealthSnapshot, stepsGoal: Int = 8_000) {
        let previous = ComplicationDataBridge.read()
        let next = ComplicationSnapshot(
            streak: previous.streak,
            gratitudeStreak: previous.gratitudeStreak,
            stepsToday: snapshot.stepsToday,
            stepsGoal: stepsGoal,
            mindfulMinutesToday: snapshot.mindfulMinutesToday,
            updatedAt: Date()
        )
        ComplicationDataBridge.write(next)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
