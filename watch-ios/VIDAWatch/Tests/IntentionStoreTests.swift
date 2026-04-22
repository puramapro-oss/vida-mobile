//
//  IntentionStoreTests.swift
//  VIDAWatchTests — P8-F2
//

import XCTest
@testable import VIDAWatch

final class IntentionStoreTests: XCTestCase {
    func testDeterministicFallbackSameDay() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let list = ["a", "b", "c"]
        let a = IntentionStore.deterministicFallback(from: list, for: date)
        let b = IntentionStore.deterministicFallback(from: list, for: date)
        XCTAssertEqual(a, b)
        XCTAssertTrue(list.contains(a))
    }

    func testDeterministicFallbackChangesNextDay() {
        let day1 = Date(timeIntervalSince1970: 1_700_000_000)
        let day2 = Date(timeIntervalSince1970: 1_700_086_400) // +1 jour
        let list = Array("abcdefghij".map { String($0) }) // 10 items to avoid edge cycles
        let a = IntentionStore.deterministicFallback(from: list, for: day1)
        let b = IntentionStore.deterministicFallback(from: list, for: day2)
        XCTAssertNotEqual(a, b)
    }

    func testEmptyFallbackListGivesBreathe() {
        let v = IntentionStore.deterministicFallback(from: [], for: Date())
        XCTAssertEqual(v, "Respire.")
    }

    @MainActor
    func testApplyRemoteUpdateSetsIntentionAndTimestamp() {
        let store = IntentionStore(client: SupabaseClient())
        store.applyRemoteUpdate("Bois un verre d'eau.")
        XCTAssertEqual(store.currentIntention, "Bois un verre d'eau.")
        XCTAssertNotNil(store.lastRefreshedAt)
    }

    @MainActor
    func testInitHasNonEmptyIntention() {
        let store = IntentionStore(client: SupabaseClient())
        XCTAssertFalse(store.currentIntention.isEmpty)
    }
}
