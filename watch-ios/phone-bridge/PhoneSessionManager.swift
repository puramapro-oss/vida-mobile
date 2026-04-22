//
//  PhoneSessionManager.swift
//  VIDA iOS phone ↔ watch bridge — P8-F5 (phone-side)
//
//  CE FICHIER EST COTE iPhone, PAS COTE watchOS. Il est ici en preparation
//  du wiring en Expo Module (post-SASU) : quand l'app RN aura signe avec
//  APPLE_TEAM_ID, on exposera ces methodes via `expo-modules-core` pour
//  que JavaScript puisse envoyer des messages a la montre.
//
//  Symetriquement au WatchSessionManager, le phone active un WCSession et
//  relaye :
//    - JWT Supabase (RN -> watch)
//    - streak/intention recalcules serveur (RN -> watch via phone)
//    - gratitudes capturees montre (watch -> RN pour upload)
//    - health snapshots offline (watch -> RN via phone)
//

import Foundation
import WatchConnectivity

@MainActor
public final class PhoneSessionManager: NSObject {
    public static let shared = PhoneSessionManager()

    public var onGratitudeCapture: ((String, Date) -> Void)?
    public var onHealthSnapshot: ((HealthSnapshot) -> Void)?
    public var onSyncRequest: (() -> Void)?

    public private(set) var isWatchAppInstalled: Bool = false
    public private(set) var isReachable: Bool = false

    private let session: WCSession

    private override init() {
        self.session = .default
        super.init()
    }

    public func activate() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }

    // MARK: - Send to watch

    public func pushAuthToken(_ token: String) {
        send(.authTokenUpdate(token: token))
    }

    public func pushStreak(streak: Int, gratitudeStreak: Int) {
        send(.streakUpdate(streak: streak, gratitudeStreak: gratitudeStreak))
    }

    public func pushIntention(_ text: String) {
        send(.intentionUpdate(text: text))
    }

    public func send(_ message: WatchMessage) {
        guard session.activationState == .activated else { return }
        guard let payload = try? WatchMessagePayload.encode(message) else { return }
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: { _ in
                self.session.transferUserInfo(payload)
            })
        } else {
            session.transferUserInfo(payload)
        }
    }
}

extension PhoneSessionManager: WCSessionDelegate {
    nonisolated public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
        }
    }

    // iOS-specific delegate methods (pas dispo watchOS) :
    #if os(iOS)
    nonisolated public func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated public func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif

    nonisolated public func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in self.isReachable = session.isReachable }
    }

    nonisolated public func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        guard let decoded = try? WatchMessagePayload.decode(from: message) else { return }
        Task { @MainActor in self.dispatch(decoded) }
    }

    nonisolated public func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        guard let decoded = try? WatchMessagePayload.decode(from: userInfo) else { return }
        Task { @MainActor in self.dispatch(decoded) }
    }

    @MainActor
    private func dispatch(_ message: WatchMessage) {
        switch message {
        case .gratitudeCapture(let text, let date):
            onGratitudeCapture?(text, date)
        case .healthSnapshotPush(let snap):
            onHealthSnapshot?(snap)
        case .syncRequest:
            onSyncRequest?()
        default:
            // Phone ne reagit pas aux messages qu'il envoie lui-meme.
            break
        }
    }
}
