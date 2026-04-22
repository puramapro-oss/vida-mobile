//
//  GratitudeView.swift
//  VIDAWatch — P8-F3
//
//  Capture rapide d'une gratitude via dictation ou 3 prompts pre-ecrits.
//  Envoi vers Supabase differé (queue locale si offline, sync via F5).
//

import SwiftUI
import WatchKit

struct GratitudeView: View {
    @Environment(StreakStore.self) private var streak
    @State private var isDictating = false
    @State private var captured: String?
    @State private var showConfirm = false

    private let prompts = [
        "Mon corps m'a permis de…",
        "J'ai souri quand…",
        "Quelqu'un m'a offert…",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.text.square.fill")
                        .foregroundStyle(.pink)
                    Text("Gratitude")
                        .font(.caption.weight(.medium))
                }
                if let captured {
                    Text("✓ \"\(captured)\"")
                        .font(.caption)
                        .foregroundStyle(VIDATheme.emerald)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Prends 10 secondes.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Button {
                        dictate()
                    } label: {
                        Label("Dicter", systemImage: "mic.fill")
                    }
                    .tint(.pink)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    ForEach(prompts, id: \.self) { prompt in
                        Button {
                            save(prompt)
                        } label: {
                            Text(prompt)
                                .font(.caption2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                    }
                }
                if streak.gratitudeStreak > 0 {
                    Label("\(streak.gratitudeStreak) jours de gratitude", systemImage: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            .padding()
        }
        .containerBackground(VIDATheme.emeraldSoft, for: .navigation)
    }

    private func dictate() {
        isDictating = true
        // WKInterfaceController presentTextInputController n'est plus appele
        // depuis SwiftUI : on utilise la TextField apple watchOS 10. Ici, on
        // simule un payload en attendant la vraie integration F5 Expo Module.
        // Fallback : passe en prompt tap en F5 si dictation indispo.
        WKInterfaceDevice.current().play(.start)
        save("Gratitude captée 🙏")
    }

    private func save(_ text: String) {
        captured = text
        WKInterfaceDevice.current().play(.success)
        // En F5, on envoie via WatchConnectivity au phone qui persiste Supabase.
    }
}

#Preview("Empty") {
    GratitudeView()
        .environment(StreakStore(client: SupabaseClient()))
}

#Preview("Captured") {
    GratitudeView()
        .environment({
            let s = StreakStore(client: SupabaseClient())
            s.applyRemoteUpdate(streak: 3, gratitudeStreak: 5)
            return s
        }())
}
