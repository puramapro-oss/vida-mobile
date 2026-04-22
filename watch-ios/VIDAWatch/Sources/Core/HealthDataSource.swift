//
//  HealthDataSource.swift
//  VIDAWatch — P8-F2
//
//  Protocole abstraction HealthKit pour permettre les mocks en tests sans
//  toucher a HKHealthStore (qui ne se mock pas naturellement).
//

import Foundation

public enum HealthError: LocalizedError, Sendable {
    case authorizationDenied
    case dataUnavailable
    case queryFailed(String)

    public var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Tu n'as pas encore autorise VIDA a lire tes donnees sante."
        case .dataUnavailable:
            return "HealthKit n'est pas disponible sur cet appareil."
        case .queryFailed(let detail):
            return "Impossible de lire tes donnees sante (\(detail))."
        }
    }
}

public protocol HealthDataSource: Sendable {
    /// Demande l'autorisation a l'utilisateur pour les types sante requis.
    /// Renvoie true si au moins READ steps + HR a ete accorde.
    func requestAuthorization() async throws -> Bool

    /// Snapshot consolidee des metriques du jour.
    func currentSnapshot() async throws -> HealthSnapshot

    /// Enregistre une session de meditation/respiration dans l'app Sante.
    /// Est un no-op si l'utilisateur n'a pas autorise WRITE mindful.
    func logMindfulSession(start: Date, end: Date) async throws
}
