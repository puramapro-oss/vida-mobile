//
//  BreathView.swift
//  VIDAWatch — P8-F3
//
//  Respiration guidee 4-4-6 (inspire / tiens / expire). Cercle qui se
//  dilate/contracte en rythme + haptic tap aux transitions.
//

import SwiftUI
import WatchKit

struct BreathView: View {
    enum Phase: String, CaseIterable {
        case inhale = "Inspire"
        case hold = "Tiens"
        case exhale = "Expire"

        var duration: TimeInterval {
            switch self {
            case .inhale: return 4
            case .hold: return 4
            case .exhale: return 6
            }
        }

        var targetScale: Double {
            switch self {
            case .inhale: return 1.0
            case .hold: return 1.0
            case .exhale: return 0.4
            }
        }

        var next: Phase {
            switch self {
            case .inhale: return .hold
            case .hold: return .exhale
            case .exhale: return .inhale
            }
        }
    }

    @State private var phase: Phase = .inhale
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var completedCycles = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(VIDATheme.emerald.opacity(0.18))
                    .frame(width: 90, height: 90)
                Circle()
                    .fill(VIDATheme.emerald.opacity(0.55))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isRunning ? phase.targetScale : 0.4)
                    .animation(.easeInOut(duration: phase.duration), value: phase)
                Text(isRunning ? phase.rawValue : "Prêt")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
            }
            .frame(height: 100)

            if isRunning {
                Text("Cycles : \(completedCycles)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Button(isRunning ? "Stop" : "Démarrer") {
                if isRunning { stop() } else { start() }
            }
            .tint(VIDATheme.emerald)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
        .containerBackground(VIDATheme.emeraldSoft, for: .navigation)
        .onDisappear { stop() }
    }

    private func start() {
        completedCycles = 0
        phase = .inhale
        isRunning = true
        WKInterfaceDevice.current().play(.start)
        scheduleNext()
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        WKInterfaceDevice.current().play(.stop)
    }

    private func scheduleNext() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: phase.duration, repeats: false) { _ in
            Task { @MainActor in
                if phase == .exhale { completedCycles += 1 }
                phase = phase.next
                WKInterfaceDevice.current().play(.directionUp)
                scheduleNext()
            }
        }
    }
}

#Preview {
    BreathView()
}
