//
//  WatchSessionManager.swift
//  VIDAWatch — P8-F5 (watch-side)
//
//  Cote montre : active WCSession, applique les messages entrants aux stores,
//  persiste les offline/outbox quand le phone est hors de portee.
//

import Foundation
import WatchConnectivity

@MainActor
public final class WatchSessionManager: NSObject {
    public static let shared = WatchSessionManager()

    public private(set) var isReachable: Bool = false
    public private(set) var isActivated: Bool = false

    private weak var streakStore: StreakStore?
    private weak var intentionStore: IntentionStore?
    private let session: WCSession

    private override init() {
        self.session = .default
        super.init()
    }

    public func activate(streakStore: StreakStore, intentionStore: IntentionStore) {
        self.streakStore = streakStore
        self.intentionStore = intentionStore
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
        drainOutbox()
    }

    // MARK: - Send

    /// Envoi preferentiel via sendMessage (live) -> fallback transferUserInfo
    /// (persiste jusqu'a next reachability).
    public func send(_ message: WatchMessage) {
        guard session.activationState == .activated else {
            queueOutbox(message)
            return
        }
        do {
            let payload = try WatchMessagePayload.encode(message)
            if session.isReachable {
                session.sendMessage(payload, replyHandler: nil) { _ in
                    // live failed -> fallback non-reachable path
                    Task { @MainActor in self.queueOutbox(message) }
                }
            } else {
                session.transferUserInfo(payload)
            }
        } catch {
            queueOutbox(message)
        }
    }

    // MARK: - Outbox (persistance simple UserDefaults)

    private static let outboxKey = "vida.watch.outbox"

    private func queueOutbox(_ message: WatchMessage) {
        var outbox = loadOutbox()
        outbox.append(message)
        persistOutbox(outbox)
    }

    private func drainOutbox() {
        let queue = loadOutbox()
        guard !queue.isEmpty else { return }
        persistOutbox([])
        for m in queue { send(m) }
    }

    private func loadOutbox() -> [WatchMessage] {
        guard let data = UserDefaults.standard.data(forKey: Self.outboxKey) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([WatchMessage].self, from: data)) ?? []
    }

    private func persistOutbox(_ messages: [WatchMessage]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(messages) {
            UserDefaults.standard.set(data, forKey: Self.outboxKey)
        }
    }

    // MARK: - Apply incoming

    func applyIncoming(_ message: WatchMessage) {
        switch message {
        case .streakUpdate(let s, let g):
            streakStore?.applyRemoteUpdate(streak: s, gratitudeStreak: g)
        case .intentionUpdate(let text):
            intentionStore?.applyRemoteUpdate(text)
        case .authTokenUpdate(let token):
            persistToken(token)
        case .ritualStarted, .ritualCompleted:
            // UI hooks a venir — pas de store dedie pour F5.
            break
        case .healthSnapshotPush, .gratitudeCapture, .syncRequest:
            // Ces messages sont normalement envoyes DEPUIS la montre ;
            // si on les recoit ici, on ignore (ping/pong safe).
            break
        }
    }

    private func persistToken(_ token: String) {
        let defaults = UserDefaults(suiteName: SupabaseClient.appGroupSuite)
            ?? .standard
        defaults.set(token, forKey: "supabase.access_token")
    }
}

extension WatchSessionManager: WCSessionDelegate {
    nonisolated public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.isActivated = activationState == .activated
            self.isReachable = session.isReachable
            if self.isActivated { self.drainOutbox() }
        }
    }

    nonisolated public func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
            if session.isReachable { self.drainOutbox() }
        }
    }

    nonisolated public func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        if let decoded = try? WatchMessagePayload.decode(from: message) {
            Task { @MainActor in self.applyIncoming(decoded) }
        }
    }

    nonisolated public func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        if let decoded = try? WatchMessagePayload.decode(from: userInfo) {
            Task { @MainActor in self.applyIncoming(decoded) }
        }
    }
}
