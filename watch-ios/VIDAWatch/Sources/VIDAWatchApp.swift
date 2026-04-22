//
//  VIDAWatchApp.swift
//  VIDAWatch
//
//  P8-F1 skeleton entry point. Full SwiftUI UI arrives in F3.
//

import SwiftUI

@main
struct VIDAWatchApp: App {
    var body: some Scene {
        WindowGroup {
            PlaceholderView()
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("VIDA")
                .font(.title2.weight(.light))
                .foregroundStyle(.tint)
            Text("Watch app scaffold")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    PlaceholderView()
}
