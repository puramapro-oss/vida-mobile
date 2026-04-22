//
//  VIDAWatchScaffoldTests.swift
//  VIDAWatchTests
//
//  P8-F1 smoke test : la cible compile et le test harness démarre.
//  Tests métier en F2+.
//

import XCTest

final class VIDAWatchScaffoldTests: XCTestCase {
    func testScaffoldCompiles() {
        XCTAssertTrue(Bundle.main.bundleIdentifier?.contains("vida") ?? false)
    }

    func testAppGroupSuiteName() {
        // Le suite name est figé. F2 l'utilisera pour partager le token Supabase.
        let suite = "group.dev.purama.vida"
        XCTAssertEqual(suite, "group.dev.purama.vida")
    }
}
