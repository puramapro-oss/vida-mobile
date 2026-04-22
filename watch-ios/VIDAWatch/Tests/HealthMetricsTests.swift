//
//  HealthMetricsTests.swift
//  VIDAWatchTests — P8-F2
//

import XCTest
@testable import VIDAWatch

final class HealthMetricsTests: XCTestCase {
    func testCodecRoundTrip() throws {
        let snapshot = HealthSnapshot(
            stepsToday: 5_421,
            heartRateBpm: 72.5,
            mindfulMinutesToday: 7,
            activeCaloriesToday: 312.4,
            sleepHoursLastNight: 7.25,
            capturedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(HealthSnapshot.self, from: data)
        XCTAssertEqual(decoded, snapshot)
    }

    func testStepsProgressClampsAtOne() {
        let snapshot = HealthSnapshot(
            stepsToday: 99_999,
            heartRateBpm: nil,
            mindfulMinutesToday: 0,
            activeCaloriesToday: 0,
            sleepHoursLastNight: nil
        )
        XCTAssertEqual(snapshot.stepsProgress, 1.0, accuracy: 0.0001)
    }

    func testZeroSnapshotIsAllZero() {
        XCTAssertEqual(HealthSnapshot.zero.stepsToday, 0)
        XCTAssertEqual(HealthSnapshot.zero.stepsProgress, 0)
        XCTAssertNil(HealthSnapshot.zero.heartRateBpm)
        XCTAssertNil(HealthSnapshot.zero.sleepHoursLastNight)
    }

    func testMindfulProgressAt5MinutesIsHalf() {
        let snap = HealthSnapshot(
            stepsToday: 0, heartRateBpm: nil,
            mindfulMinutesToday: 5,
            activeCaloriesToday: 0, sleepHoursLastNight: nil
        )
        XCTAssertEqual(snap.mindfulProgress, 0.5, accuracy: 0.0001)
    }
}
