//
//  StepsComplication.swift
//  VIDAWatchComplication — P8-F4
//
//  Complication steps circulaire (ring progress 0-100%) + corner.
//

import WidgetKit
import SwiftUI

struct StepsEntry: TimelineEntry {
    let date: Date
    let snapshot: ComplicationSnapshot
}

struct StepsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepsEntry {
        StepsEntry(date: .now, snapshot: ComplicationSnapshot(stepsToday: 4200, stepsGoal: 8000))
    }

    func getSnapshot(in context: Context, completion: @escaping (StepsEntry) -> Void) {
        completion(StepsEntry(date: .now, snapshot: ComplicationDataBridge.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepsEntry>) -> Void) {
        let entry = StepsEntry(date: .now, snapshot: ComplicationDataBridge.read())
        let nextReload = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextReload)))
    }
}

struct StepsComplicationView: View {
    @Environment(\.widgetFamily) var family
    let entry: StepsEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            circular
        case .accessoryCorner:
            corner
        default:
            inline
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            Gauge(
                value: entry.snapshot.stepsProgress,
                in: 0...1,
                label: { Text("Pas") },
                currentValueLabel: {
                    Text("\(entry.snapshot.stepsToday / 1_000)K")
                        .font(.caption2.monospacedDigit())
                }
            )
            .gaugeStyle(.accessoryCircularCapacity)
        }
        .widgetAccentable()
    }

    private var corner: some View {
        Text("\(entry.snapshot.stepsToday)")
            .font(.caption.monospacedDigit())
            .widgetLabel {
                ProgressView(value: entry.snapshot.stepsProgress)
                    .tint(.green)
            }
    }

    private var inline: some View {
        Text("\(entry.snapshot.stepsToday)/\(entry.snapshot.stepsGoal) pas")
            .font(.caption.monospacedDigit())
    }
}

struct StepsComplication: Widget {
    let kind: String = "StepsComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepsProvider()) { entry in
            StepsComplicationView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Pas VIDA")
        .description("Ton objectif pas du jour.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
        ])
    }
}
