//
//  SupabaseClientTests.swift
//  VIDAWatchTests — P8-F2
//

import XCTest
@testable import VIDAWatch

final class SupabaseClientTests: XCTestCase {
    func testAppGroupSuiteName() {
        XCTAssertEqual(SupabaseClient.appGroupSuite, "group.dev.purama.vida")
    }

    func testSchemaIsVidaSante() {
        XCTAssertEqual(SupabaseClient.schema, "vida_sante")
    }

    func testDefaultBaseURLIsAuthPurama() {
        XCTAssertEqual(SupabaseClient.defaultBaseURL.absoluteString, "https://auth.purama.dev")
    }

    func testCurrentAccessTokenReturnsTokenFromDefaults() async {
        let suite = "test.vida.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.set("jwt-xxx", forKey: "supabase.access_token")
        defer { UserDefaults().removePersistentDomain(forName: suite) }
        let client = SupabaseClient(defaults: defaults)
        let token = await client.currentAccessToken()
        XCTAssertEqual(token, "jwt-xxx")
    }

    func testCurrentAccessTokenNilWhenEmpty() async {
        let suite = "test.vida.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { UserDefaults().removePersistentDomain(forName: suite) }
        let client = SupabaseClient(defaults: defaults)
        let token = await client.currentAccessToken()
        XCTAssertNil(token)
    }

    func testWatchProfileDecodesSnakeCase() throws {
        let json = """
        {"streak": 10, "current_intention": "Marche 10 min", "gratitude_streak": 3}
        """.data(using: .utf8)!
        let profile = try JSONDecoder().decode(WatchProfile.self, from: json)
        XCTAssertEqual(profile.streak, 10)
        XCTAssertEqual(profile.currentIntention, "Marche 10 min")
        XCTAssertEqual(profile.gratitudeStreak, 3)
    }
}
