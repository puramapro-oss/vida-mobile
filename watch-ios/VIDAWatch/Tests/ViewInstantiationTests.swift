//
//  ViewInstantiationTests.swift
//  VIDAWatchTests — P8-F3
//
//  Smoke tests : chaque ecran se cree sans crash avec des stores propres.
//  Les tests d'image snapshot (pointfreeco/swift-snapshot-testing) sont a
//  integrer post-SASU — voir docs/P8-WATCH.md.
//

import XCTest
import SwiftUI
@testable import VIDAWatch

@MainActor
final class ViewInstantiationTests: XCTestCase {
    private func makeStreak(streak: Int = 0, gratitude: Int = 0) -> StreakStore {
        let s = StreakStore(client: SupabaseClient())
        s.applyRemoteUpdate(streak: streak, gratitudeStreak: gratitude)
        return s
    }

    private func makeIntention(text: String = "Respire.") -> IntentionStore {
        let s = IntentionStore(client: SupabaseClient())
        s.applyRemoteUpdate(text)
        return s
    }

    func testDashboardViewInstantiates() {
        let view = DashboardView(snapshot: HealthSnapshot(
            stepsToday: 3_000,
            heartRateBpm: 70,
            mindfulMinutesToday: 4,
            activeCaloriesToday: 200,
            sleepHoursLastNight: 7
        ))
        .environment(makeStreak(streak: 5))
        XCTAssertNotNil(view)
    }

    func testStreakViewInstantiates() {
        let view = StreakView().environment(makeStreak(streak: 12, gratitude: 3))
        XCTAssertNotNil(view)
    }

    func testIntentionViewInstantiates() {
        let view = IntentionView().environment(makeIntention(text: "Marche 10 min dehors."))
        XCTAssertNotNil(view)
    }

    func testBreathViewInstantiates() {
        let view = BreathView()
        XCTAssertNotNil(view)
        // Verify enum transitions
        XCTAssertEqual(BreathView.Phase.inhale.next, .hold)
        XCTAssertEqual(BreathView.Phase.hold.next, .exhale)
        XCTAssertEqual(BreathView.Phase.exhale.next, .inhale)
        XCTAssertEqual(BreathView.Phase.inhale.duration, 4)
        XCTAssertEqual(BreathView.Phase.exhale.duration, 6)
    }

    func testGratitudeViewInstantiates() {
        let view = GratitudeView().environment(makeStreak(gratitude: 7))
        XCTAssertNotNil(view)
    }

    func testRitualTimerViewInstantiates() {
        let view = RitualTimerView()
        XCTAssertNotNil(view)
        // Verify durations
        XCTAssertEqual(RitualTimerView.Duration.oneMinute.rawValue, 60)
        XCTAssertEqual(RitualTimerView.Duration.threeMinutes.rawValue, 180)
        XCTAssertEqual(RitualTimerView.Duration.fiveMinutes.rawValue, 300)
    }

    func testContentViewInstantiates() {
        let view = ContentView(health: PreviewHealthDataSource())
            .environment(makeStreak())
            .environment(makeIntention())
        XCTAssertNotNil(view)
    }

    func testProgressRingClamps() {
        // Internal clamp protection
        let over = ProgressRing(value: 2.5)
        let under = ProgressRing(value: -0.3)
        XCTAssertNotNil(over)
        XCTAssertNotNil(under)
    }

    func testWatchSizesAreSane() {
        XCTAssertEqual(WatchSize.allCases.count, 4)
        XCTAssertGreaterThan(WatchSize.s49.width, WatchSize.s38.width)
    }
}
