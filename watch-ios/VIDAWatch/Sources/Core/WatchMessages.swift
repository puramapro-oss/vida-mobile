//
//  WatchMessages.swift
//  VIDAWatch — P8-F5
//
//  Protocole de messages watch ↔ phone. Codable enum avec associated values,
//  encode en JSON tag-based via le mecanisme Swift 5.5+.
//

import Foundation

public enum WatchMessage: Codable, Equatable, Sendable {
    /// Phone → watch : nouveau JWT Supabase (apres login / refresh).
    case authTokenUpdate(token: String)

    /// Phone → watch : valeurs streak calculees cote serveur.
    case streakUpdate(streak: Int, gratitudeStreak: Int)

    /// Phone → watch : intention du jour (generee par IA cote serveur).
    case intentionUpdate(text: String)

    /// Watch → phone : l'utilisateur a capture une gratitude.
    case gratitudeCapture(text: String, capturedAt: Date)

    /// Watch → phone : snapshot sante pour upload Supabase (offline queue).
    case healthSnapshotPush(snapshot: HealthSnapshot)

    /// Watch → phone : demande le dernier state serveur.
    case syncRequest

    /// Phone → watch : session rituel demarree (pour badge complication).
    case ritualStarted(durationSeconds: Int)

    /// Phone → watch : session rituel terminee.
    case ritualCompleted(durationSeconds: Int)
}

/// Helper d'encodage : Dictionary<String, Any> pour WatchConnectivity qui
/// n'accepte pas Codable directement. On passe par JSON Data puis reserializer.
public enum WatchMessagePayload {
    public static let key = "payload"

    /// Encode pour passer via WCSession.sendMessage / transferUserInfo.
    public static func encode(_ message: WatchMessage) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(message)
        guard let string = String(data: data, encoding: .utf8) else {
            throw WatchMessageError.encodingFailed
        }
        return [key: string]
    }

    public static func decode(from dict: [String: Any]) throws -> WatchMessage {
        guard let string = dict[key] as? String,
              let data = string.data(using: .utf8) else {
            throw WatchMessageError.missingPayload
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(WatchMessage.self, from: data)
    }
}

public enum WatchMessageError: LocalizedError, Sendable {
    case encodingFailed
    case missingPayload
    case sessionNotReachable

    public var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Impossible d'encoder le message."
        case .missingPayload: return "Message vide ou mal forme."
        case .sessionNotReachable: return "La montre et le telephone ne communiquent pas."
        }
    }
}
