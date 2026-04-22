//
//  StreakStoreTests.swift
//  VIDAWatchTests — P8-F2
//

import XCTest
@testable import VIDAWatch

final class StreakStoreTests: XCTestCase {
    @MainActor
    func testInitialStreakIsZero() {
        let store = StreakStore(client: SupabaseClient())
        XCTAssertEqual(store.streak, 0)
        XCTAssertEqual(store.gratitudeStreak, 0)
        XCTAssertNil(store.lastRefreshedAt)
    }

    @MainActor
    func testApplyRemoteUpdateSetsAllFields() {
        let store = StreakStore(client: SupabaseClient())
        store.applyRemoteUpdate(streak: 12, gratitudeStreak: 7)
        XCTAssertEqual(store.streak, 12)
        XCTAssertEqual(store.gratitudeStreak, 7)
        XCTAssertNotNil(store.lastRefreshedAt)
    }

    @MainActor
    func testRefreshWithoutTokenSetsError() async {
        // Aucun token en UserDefaults.standard dans env test => notAuthenticated
        // attendu. Utilise un suite isole pour eviter de polluer.
        let suite = "test.vida.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { UserDefaults().removePersistentDomain(forName: suite) }
        let client = SupabaseClient(defaults: defaults)
        let store = StreakStore(client: client)
        await store.refresh()
        XCTAssertNotNil(store.lastError)
        XCTAssertFalse(store.isLoading)
    }
}
