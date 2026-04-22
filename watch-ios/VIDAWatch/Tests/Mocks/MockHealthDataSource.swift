//
//  MockHealthDataSource.swift
//  VIDAWatchTests — P8-F2
//

import Foundation
@testable import VIDAWatch

actor MockHealthDataSource: HealthDataSource {
    private var nextSnapshot: HealthSnapshot
    private var shouldThrow: HealthError?
    private(set) var loggedSessions: [(Date, Date)] = []

    init(
        snapshot: HealthSnapshot = .zero,
        throwing: HealthError? = nil
    ) {
        self.nextSnapshot = snapshot
        self.shouldThrow = throwing
    }

    func setSnapshot(_ snap: HealthSnapshot) { self.nextSnapshot = snap }
    func setError(_ err: HealthError?) { self.shouldThrow = err }

    nonisolated func requestAuthorization() async throws -> Bool {
        if let err = await shouldThrow { throw err }
        return true
    }

    nonisolated func currentSnapshot() async throws -> HealthSnapshot {
        if let err = await shouldThrow { throw err }
        return await nextSnapshot
    }

    nonisolated func logMindfulSession(start: Date, end: Date) async throws {
        if let err = await shouldThrow { throw err }
        await appendSession(start: start, end: end)
    }

    private func appendSession(start: Date, end: Date) {
        loggedSessions.append((start, end))
    }
}
