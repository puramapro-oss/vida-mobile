//
//  HealthKitManager.swift
//  VIDAWatch — P8-F2
//
//  Implementation reelle du HealthDataSource via HealthKit.
//  Unite : Steps (count), Heart Rate (BPM), Active Energy (kcal),
//  Mindful (durations), Sleep (duree analyse).
//

import Foundation
import HealthKit

public final class HealthKitManager: HealthDataSource {
    private let store: HKHealthStore

    public init(store: HKHealthStore = .init()) {
        self.store = store
    }

    // MARK: - Types

    private static let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        if let t = HKQuantityType.quantityType(forIdentifier: .stepCount) { types.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .heartRate) { types.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) { types.insert(t) }
        if let t = HKCategoryType.categoryType(forIdentifier: .mindfulSession) { types.insert(t) }
        if let t = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(t) }
        return types
    }()

    private static let writeTypes: Set<HKSampleType> = {
        var types = Set<HKSampleType>()
        if let t = HKCategoryType.categoryType(forIdentifier: .mindfulSession) { types.insert(t) }
        return types
    }()

    // MARK: - Authorization

    public func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthError.dataUnavailable
        }
        try await store.requestAuthorization(
            toShare: Self.writeTypes,
            read: Self.readTypes
        )
        // HealthKit ne dit pas si read a ete accorde pour raisons de confidentialite.
        // On teste via une query 1-sample steps.
        return try await canReadSteps()
    }

    private func canReadSteps() async throws -> Bool {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return false
        }
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: .init()),
            end: .init()
        )
        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(
                sampleType: stepType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error { cont.resume(throwing: HealthError.queryFailed(error.localizedDescription)); return }
                cont.resume(returning: samples != nil)
            }
            store.execute(query)
        }
    }

    // MARK: - Snapshot

    public func currentSnapshot() async throws -> HealthSnapshot {
        async let steps = quantitySumToday(identifier: .stepCount, unit: .count())
        async let calories = quantitySumToday(identifier: .activeEnergyBurned, unit: .kilocalorie())
        async let mindful = mindfulMinutesToday()
        async let heart = latestHeartRate()
        async let sleep = sleepHoursLastNight()

        return try await HealthSnapshot(
            stepsToday: Int(steps),
            heartRateBpm: heart,
            mindfulMinutesToday: mindful,
            activeCaloriesToday: calories,
            sleepHoursLastNight: sleep
        )
    }

    private func quantitySumToday(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit
    ) async throws -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            return 0
        }
        let startOfDay = Calendar.current.startOfDay(for: .init())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .init())
        return try await withCheckedThrowingContinuation { cont in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, error in
                if let error {
                    cont.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                let value = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0
                cont.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func latestHeartRate() async throws -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    cont.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                guard let sample = samples?.first as? HKQuantitySample else {
                    cont.resume(returning: nil); return
                }
                let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                cont.resume(returning: sample.quantity.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }

    private func mindfulMinutesToday() async throws -> Int {
        guard let type = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: .init())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: .init())
        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    cont.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                let total = (samples ?? []).reduce(0) { acc, s in
                    acc + Int(s.endDate.timeIntervalSince(s.startDate) / 60)
                }
                cont.resume(returning: total)
            }
            store.execute(query)
        }
    }

    private func sleepHoursLastNight() async throws -> Double? {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        // Fenetre : hier 18h -> aujourd'hui 12h
        let cal = Calendar.current
        let now = Date()
        let todayNoon = cal.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
        let yesterdayEvening = cal.date(byAdding: .hour, value: -18, to: todayNoon) ?? now
        let predicate = HKQuery.predicateForSamples(withStart: yesterdayEvening, end: todayNoon)
        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    cont.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                let asleep = (samples ?? []).compactMap { $0 as? HKCategorySample }
                    .filter {
                        // iOS 16+ : .asleepCore/.asleepDeep/.asleepREM
                        // iOS < 16 : .asleep
                        if #available(watchOS 9.0, *) {
                            return [
                                HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                                HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                                HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                            ].contains($0.value)
                        } else {
                            return $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue
                        }
                    }
                guard !asleep.isEmpty else { cont.resume(returning: nil); return }
                let seconds = asleep.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                cont.resume(returning: seconds / 3_600)
            }
            store.execute(query)
        }
    }

    // MARK: - Write

    public func logMindfulSession(start: Date, end: Date) async throws {
        guard let type = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            throw HealthError.dataUnavailable
        }
        let sample = HKCategorySample(
            type: type,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        try await store.save(sample)
    }
}
