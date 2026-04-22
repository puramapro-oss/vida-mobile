//
//  StreakComplication.swift
//  VIDAWatchComplication — P8-F4
//
//  Complication streak 🔥 sur 4 familles : circular, corner, inline, rectangular.
//  Timeline rafraichie toutes les 30 min (budget complication Apple limite).
//

import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let snapshot: ComplicationSnapshot

    static let placeholder = StreakEntry(
        date: .init(),
        snapshot: ComplicationSnapshot(streak: 7, gratitudeStreak: 3, stepsToday: 4200, mindfulMinutesToday: 6)
    )
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: .now, snapshot: ComplicationDataBridge.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let snap = ComplicationDataBridge.read()
        let entry = StreakEntry(date: .now, snapshot: snap)
        // Reload policy : toutes les 30 min pour respecter le budget complication.
        let nextReload = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextReload)))
    }
}

struct StreakComplicationView: View {
    @Environment(\.widgetFamily) var family
    let entry: StreakEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            circular
        case .accessoryCorner:
            corner
        case .accessoryInline:
            inline
        case .accessoryRectangular:
            rectangular
        default:
            inline
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("🔥").font(.system(size: 14))
                Text("\(entry.snapshot.streak)").font(.caption.monospacedDigit().bold())
            }
        }
        .widgetAccentable()
    }

    private var corner: some View {
        Text("🔥 \(entry.snapshot.streak)")
            .font(.caption.monospacedDigit().bold())
            .widgetLabel("Streak VIDA")
    }

    private var inline: some View {
        Text("🔥 \(entry.snapshot.streak) j · 💜 \(entry.snapshot.gratitudeStreak)")
            .font(.caption.monospacedDigit())
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text("🔥").font(.title3)
                Text("\(entry.snapshot.streak) jours")
                    .font(.caption.monospacedDigit().bold())
            }
            Text("\(entry.snapshot.gratitudeStreak) gratitudes · \(entry.snapshot.mindfulMinutesToday) min mindful")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .widgetAccentable()
    }
}

struct StreakComplication: Widget {
    let kind: String = "StreakComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakComplicationView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Streak VIDA")
        .description("Ton streak quotidien au poignet.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular,
        ])
    }
}
