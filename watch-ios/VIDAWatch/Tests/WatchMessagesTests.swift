//
//  WatchMessagesTests.swift
//  VIDAWatchTests — P8-F5
//

import XCTest
@testable import VIDAWatch

final class WatchMessagesTests: XCTestCase {

    func testAuthTokenUpdateCodec() throws {
        try roundTrip(.authTokenUpdate(token: "jwt-abc-123"))
    }

    func testStreakUpdateCodec() throws {
        try roundTrip(.streakUpdate(streak: 14, gratitudeStreak: 5))
    }

    func testIntentionUpdateCodec() throws {
        try roundTrip(.intentionUpdate(text: "Bois un verre d'eau maintenant."))
    }

    func testGratitudeCaptureCodec() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        try roundTrip(.gratitudeCapture(text: "Merci pour cette vue.", capturedAt: date))
    }

    func testHealthSnapshotPushCodec() throws {
        let snap = HealthSnapshot(
            stepsToday: 5_200,
            heartRateBpm: 68,
            mindfulMinutesToday: 7,
            activeCaloriesToday: 280,
            sleepHoursLastNight: 7.2,
            capturedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        try roundTrip(.healthSnapshotPush(snapshot: snap))
    }

    func testSyncRequestCodec() throws {
        try roundTrip(.syncRequest)
    }

    func testRitualStartedCodec() throws {
        try roundTrip(.ritualStarted(durationSeconds: 180))
    }

    func testRitualCompletedCodec() throws {
        try roundTrip(.ritualCompleted(durationSeconds: 300))
    }

    func testPayloadEncodeGivesDictWithPayloadKey() throws {
        let dict = try WatchMessagePayload.encode(.syncRequest)
        XCTAssertNotNil(dict[WatchMessagePayload.key])
    }

    func testPayloadDecodeMissingKey() {
        XCTAssertThrowsError(try WatchMessagePayload.decode(from: [:]))
    }

    func testPayloadDecodeMalformedString() {
        XCTAssertThrowsError(try WatchMessagePayload.decode(from: [WatchMessagePayload.key: "not-json"]))
    }

    // MARK: - helpers

    private func roundTrip(_ message: WatchMessage, file: StaticString = #file, line: UInt = #line) throws {
        let payload = try WatchMessagePayload.encode(message)
        let decoded = try WatchMessagePayload.decode(from: payload)
        XCTAssertEqual(decoded, message, file: file, line: line)
    }
}
