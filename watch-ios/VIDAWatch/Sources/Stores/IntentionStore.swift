//
//  IntentionStore.swift
//  VIDAWatch — P8-F2
//
//  Observable store pour l'intention du jour. La liste fallback ci-dessous
//  garantit que l'ecran IntentionView a toujours du contenu, meme hors-ligne
//  ou avant premier sync Supabase.
//

import Foundation
import Observation

@MainActor
@Observable
public final class IntentionStore {
    public private(set) var currentIntention: String
    public private(set) var lastRefreshedAt: Date?
    public private(set) var isLoading: Bool = false
    public private(set) var lastError: String?

    private let client: SupabaseClient
    private let fallbacks: [String]

    public static let defaultFallbacks = [
        "Respire. Tu fais de ton mieux, et c'est deja beaucoup.",
        "Aujourd'hui, choisis un petit geste de douceur envers toi-meme.",
        "Ton corps garde la sagesse. Ecoute-le.",
        "Chaque pas, meme lent, te rapproche de toi.",
        "Le silence est aussi une reponse.",
        "Tu n'as rien a prouver. Juste a etre.",
    ]

    public init(client: SupabaseClient, fallbacks: [String] = IntentionStore.defaultFallbacks) {
        self.client = client
        self.fallbacks = fallbacks
        // Intention par defaut deterministe/jour pour eviter le flash vide au launch.
        self.currentIntention = Self.deterministicFallback(from: fallbacks, for: .init())
    }

    public func refresh() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            let profile = try await client.fetchProfile()
            if let remote = profile.currentIntention, !remote.isEmpty {
                self.currentIntention = remote
            } else {
                self.currentIntention = Self.deterministicFallback(from: fallbacks, for: .init())
            }
            self.lastRefreshedAt = Date()
        } catch {
            self.lastError = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            // Pas d'autoreset — on garde le dernier known-good.
        }
    }

    public func applyRemoteUpdate(_ text: String) {
        self.currentIntention = text
        self.lastRefreshedAt = Date()
    }

    /// Determinisme par jour de l'annee pour eviter un nouveau message a chaque
    /// wake up de la montre.
    static func deterministicFallback(from list: [String], for date: Date) -> String {
        guard !list.isEmpty else { return "Respire." }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return list[dayOfYear % list.count]
    }
}
