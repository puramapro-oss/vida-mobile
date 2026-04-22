//
//  IntentionView.swift
//  VIDAWatch — P8-F3
//

import SwiftUI

struct IntentionView: View {
    @Environment(IntentionStore.self) private var intention

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(VIDATheme.emerald)
                    Text("Intention du jour")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Text(intention.currentIntention)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                if intention.isLoading {
                    ProgressView().tint(VIDATheme.emerald)
                } else if intention.lastError != nil {
                    Text("Hors-ligne")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .containerBackground(VIDATheme.emeraldSoft, for: .navigation)
    }
}

#Preview {
    IntentionView()
        .environment({
            let s = IntentionStore(client: SupabaseClient())
            s.applyRemoteUpdate("Fais 3 minutes de respiration consciente avant ton prochain repas.")
            return s
        }())
}
