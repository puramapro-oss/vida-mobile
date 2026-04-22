//
//  ComplicationBridgeTests.swift
//  VIDAWatchTests — P8-F4
//

import XCTest
@testable import VIDAWatch

final class ComplicationBridgeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clean shared state between tests.
        UserDefaults(suiteName: ComplicationDataBridge.appGroupSuite)?.removeObject(forKey: ComplicationDataBridge.storageKey)
        UserDefaults.standard.removeObject(forKey: ComplicationDataBridge.storageKey)
    }

    func testReadWhenEmptyReturnsZero() {
        XCTAssertEqual(ComplicationDataBridge.read().streak, 0)
        XCTAssertEqual(ComplicationDataBridge.read().stepsToday, 0)
    }

    func testWriteThenRead() {
        let snap = ComplicationSnapshot(
            streak: 15, gratitudeStreak: 4,
            stepsToday: 6_000, stepsGoal: 10_000,
            mindfulMinutesToday: 8
        )
        XCTAssertTrue(ComplicationDataBridge.write(snap))
        let read = ComplicationDataBridge.read()
        XCTAssertEqual(read.streak, 15)
        XCTAssertEqual(read.gratitudeStreak, 4)
        XCTAssertEqual(read.stepsToday, 6_000)
        XCTAssertEqual(read.stepsGoal, 10_000)
        XCTAssertEqual(read.mindfulMinutesToday, 8)
    }

    func testStepsProgressClampsAtOne() {
        let snap = ComplicationSnapshot(stepsToday: 99_999, stepsGoal: 8_000)
        XCTAssertEqual(snap.stepsProgress, 1.0, accuracy: 0.0001)
    }

    func testStepsProgressHalf() {
        let snap = ComplicationSnapshot(stepsToday: 4_000, stepsGoal: 8_000)
        XCTAssertEqual(snap.stepsProgress, 0.5, accuracy: 0.0001)
    }

    func testZeroGoalDoesNotCrash() {
        // init clamps min goal to 1 to avoid divide-by-zero
        let snap = ComplicationSnapshot(stepsToday: 500, stepsGoal: 0)
        XCTAssertGreaterThanOrEqual(snap.stepsProgress, 0)
        XCTAssertLessThanOrEqual(snap.stepsProgress, 1.0)
    }

    func testCodecRoundTrip() throws {
        let snap = ComplicationSnapshot(
            streak: 9, gratitudeStreak: 2,
            stepsToday: 5_000, stepsGoal: 8_000, mindfulMinutesToday: 5,
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snap)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ComplicationSnapshot.self, from: data)
        XCTAssertEqual(decoded, snap)
    }

    @MainActor
    func testHealthComplicationSyncMergesWithExistingStreak() {
        let existing = ComplicationSnapshot(streak: 20, gratitudeStreak: 5)
        ComplicationDataBridge.write(existing)
        let health = HealthSnapshot(
            stepsToday: 7_500, heartRateBpm: 72,
            mindfulMinutesToday: 12, activeCaloriesToday: 380,
            sleepHoursLastNight: 7
        )
        HealthComplicationSync.sync(from: health, stepsGoal: 8_000)
        let merged = ComplicationDataBridge.read()
        XCTAssertEqual(merged.streak, 20, "streak preserved")
        XCTAssertEqual(merged.gratitudeStreak, 5, "gratitude preserved")
        XCTAssertEqual(merged.stepsToday, 7_500, "steps updated")
        XCTAssertEqual(merged.mindfulMinutesToday, 12, "mindful updated")
    }
}
