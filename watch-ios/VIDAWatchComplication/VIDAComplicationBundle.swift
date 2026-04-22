//
//  VIDAComplicationBundle.swift
//  VIDAWatchComplication
//
//  P8-F1 skeleton WidgetBundle. Real complications arrive in F4.
//

import WidgetKit
import SwiftUI

@main
struct VIDAComplicationBundle: WidgetBundle {
    var body: some Widget {
        PlaceholderComplication()
    }
}

struct PlaceholderComplication: Widget {
    let kind: String = "VIDAPlaceholder"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlaceholderProvider()) { _ in
            Text("VIDA")
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("VIDA")
        .description("Connexion à venir")
        .supportedFamilies([.accessoryInline, .accessoryCircular])
    }
}

struct PlaceholderEntry: TimelineEntry {
    let date: Date
}

struct PlaceholderProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlaceholderEntry {
        PlaceholderEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (PlaceholderEntry) -> Void) {
        completion(PlaceholderEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlaceholderEntry>) -> Void) {
        completion(Timeline(entries: [PlaceholderEntry(date: .now)], policy: .atEnd))
    }
}
