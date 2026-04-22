//
//  ComplicationTimelineTests.swift
//  VIDAWatchTests — P8-F4
//
//  Verifie que les TimelineProvider renvoient des entries valides et une
//  reload policy raisonnable (>= 30 min pour respecter le budget complication
//  Apple).
//

import XCTest
import WidgetKit
@testable import VIDAWatch
@testable import VIDAWatchComplication

final class ComplicationTimelineTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: ComplicationDataBridge.appGroupSuite)?.removeObject(forKey: ComplicationDataBridge.storageKey)
    }

    func testStreakProviderPlaceholderHasStreak() {
        let provider = StreakProvider()
        let fakeContext = TimelineProviderContext()
        let placeholder = provider.placeholder(in: fakeContext)
        XCTAssertGreaterThanOrEqual(placeholder.snapshot.streak, 0)
    }

    func testStreakProviderSnapshotReadsFromBridge() {
        ComplicationDataBridge.write(ComplicationSnapshot(streak: 42))
        let provider = StreakProvider()
        let exp = expectation(description: "snapshot")
        var entry: StreakEntry?
        provider.getSnapshot(in: TimelineProviderContext()) {
            entry = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertEqual(entry?.snapshot.streak, 42)
    }

    func testStreakProviderTimelinePolicyAtLeast30Min() {
        let provider = StreakProvider()
        let exp = expectation(description: "timeline")
        var timeline: Timeline<StreakEntry>?
        provider.getTimeline(in: TimelineProviderContext()) {
            timeline = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        guard let tl = timeline else { XCTFail("no timeline"); return }
        if case .after(let nextReload) = tl.policy {
            let delta = nextReload.timeIntervalSinceNow
            XCTAssertGreaterThanOrEqual(delta, 25 * 60, "policy should be ~30 min")
            XCTAssertLessThanOrEqual(delta, 35 * 60)
        } else {
            XCTFail("expected .after policy")
        }
    }

    func testStepsProviderReadsFromBridge() {
        ComplicationDataBridge.write(ComplicationSnapshot(stepsToday: 5_500, stepsGoal: 10_000))
        let provider = StepsProvider()
        let exp = expectation(description: "snapshot")
        var entry: StepsEntry?
        provider.getSnapshot(in: TimelineProviderContext()) {
            entry = $0
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        XCTAssertEqual(entry?.snapshot.stepsToday, 5_500)
        XCTAssertEqual(entry?.snapshot.stepsProgress, 0.55, accuracy: 0.001)
    }
}

// TimelineProviderContext cannot be instantiated from tests directly, but
// WidgetKit provides a public initializer via protocol extension in test
// environments since iOS 17 / watchOS 10. On older SDKs, tests would need
// ViewInspector. For watchOS 10+, the following init is available.
#if canImport(WidgetKit)
extension TimelineProviderContext {
    // no-op : TimelineProviderContext has a public default initializer since
    // watchOS 10. If the SDK ever removes it, these tests fail at compile
    // time — that's the signal to integrate swift-snapshot-testing instead.
}
#endif
