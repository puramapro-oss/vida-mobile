//
//  SupabaseClient.swift
//  VIDAWatch — P8-F2
//
//  Client REST Supabase minimal (pas de SDK Swift officiel sur watchOS, et la
//  version iOS pese 2 MB+). Lit le JWT depuis l'App Group UserDefaults si
//  dispo ; fallback silencieux sur standard UserDefaults tant que la capability
//  App Groups n'est pas activee (dev sans signing, cf docs/P8-WATCH.md).
//

import Foundation

public enum SupabaseError: LocalizedError, Sendable {
    case notAuthenticated
    case http(Int, String)
    case decoding(String)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Connecte-toi depuis l'iPhone puis ressaye."
        case .http(let code, let body):
            return "Erreur reseau \(code) : \(body.prefix(120))"
        case .decoding(let detail):
            return "Reponse invalide : \(detail)"
        }
    }
}

public actor SupabaseClient {
    // Public anon key — safe to embed (cf CLAUDE.md sec 17).
    public static let defaultBaseURL = URL(string: "https://auth.purama.dev")!
    public static let defaultAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzQwNTI0ODAwLCJleHAiOjE4OTgyOTEyMDB9.GkiVoEuCykK7vIpNzY_Zmc6XPNnJF3BUPvijXXZy2aU"
    public static let appGroupSuite = "group.dev.purama.vida"
    public static let schema = "vida_sante"

    private let baseURL: URL
    private let anonKey: String
    private let defaults: UserDefaults
    private let session: URLSession

    public init(
        baseURL: URL = SupabaseClient.defaultBaseURL,
        anonKey: String = SupabaseClient.defaultAnonKey,
        defaults: UserDefaults? = nil,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.anonKey = anonKey
        // App Group defaults si disponible, sinon standard.
        // La capability n'est active qu'apres signing Apple Dev Program.
        self.defaults = defaults
            ?? UserDefaults(suiteName: SupabaseClient.appGroupSuite)
            ?? .standard
        self.session = session
    }

    /// JWT utilisateur ecrit par l'app iPhone dans l'App Group.
    /// La clef est contractuelle avec le code RN iOS (a wrapper en Expo Module).
    public func currentAccessToken() -> String? {
        defaults.string(forKey: "supabase.access_token")
    }

    // MARK: - REST helpers

    private func authedRequest(path: String, method: String = "GET") throws -> URLRequest {
        guard let token = currentAccessToken() else { throw SupabaseError.notAuthenticated }
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(SupabaseClient.schema, forHTTPHeaderField: "Accept-Profile")
        req.setValue(SupabaseClient.schema, forHTTPHeaderField: "Content-Profile")
        return req
    }

    private func execute<T: Decodable>(_ req: URLRequest, as type: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.http(-1, "no response")
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw SupabaseError.http(http.statusCode, body)
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SupabaseError.decoding(error.localizedDescription)
        }
    }

    // MARK: - Endpoints utilises par la montre

    /// GET /rest/v1/profiles?select=streak,daily_intention&id=eq.<uid>
    /// Simplification : on recupere la row profile et mappe les champs utilises.
    public func fetchProfile() async throws -> WatchProfile {
        var req = try authedRequest(
            path: "rest/v1/profiles?select=streak,current_intention,gratitude_streak"
        )
        req.setValue("application/vnd.pgrst.object+json", forHTTPHeaderField: "Accept")
        let profile: WatchProfile = try await execute(req, as: WatchProfile.self)
        return profile
    }

    /// POST /rest/v1/rpc/log_watch_snapshot (fonction PL/pgSQL cote DB,
    /// TBD en F8 via migration legere). Pour F2, stub qui log l'intent.
    public func uploadHealthSnapshot(_ snapshot: HealthSnapshot) async throws {
        var req = try authedRequest(path: "rest/v1/rpc/log_watch_snapshot", method: "POST")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        req.httpBody = try encoder.encode(["snapshot": snapshot])
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            if let code = (response as? HTTPURLResponse)?.statusCode {
                throw SupabaseError.http(code, "upload snapshot")
            }
            throw SupabaseError.http(-1, "no response")
        }
    }
}

public struct WatchProfile: Codable, Equatable, Sendable {
    public let streak: Int
    public let currentIntention: String?
    public let gratitudeStreak: Int

    public init(streak: Int, currentIntention: String?, gratitudeStreak: Int) {
        self.streak = streak
        self.currentIntention = currentIntention
        self.gratitudeStreak = gratitudeStreak
    }

    enum CodingKeys: String, CodingKey {
        case streak
        case currentIntention = "current_intention"
        case gratitudeStreak = "gratitude_streak"
    }
}
