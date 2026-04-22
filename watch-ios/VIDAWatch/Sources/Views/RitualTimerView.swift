//
//  RitualTimerView.swift
//  VIDAWatch — P8-F3
//
//  Timer micro-rituel (1, 3, 5 min). Haptics toutes les 60s + final gong.
//

import SwiftUI
import WatchKit

struct RitualTimerView: View {
    enum Duration: Int, CaseIterable, Identifiable {
        case oneMinute = 60, threeMinutes = 180, fiveMinutes = 300
        var id: Int { rawValue }
        var label: String {
            switch self {
            case .oneMinute: return "1 min"
            case .threeMinutes: return "3 min"
            case .fiveMinutes: return "5 min"
            }
        }
    }

    @State private var selectedDuration: Duration = .threeMinutes
    @State private var remaining: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 10) {
            if !isRunning {
                Text("Rituel silence")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Picker("Durée", selection: $selectedDuration) {
                    ForEach(Duration.allCases) { d in
                        Text(d.label).tag(d)
                    }
                }
                .pickerStyle(.navigationLink)
                .frame(height: 30)
                Button("Commencer") { start() }
                    .tint(VIDATheme.deepViolet)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            } else {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 6)
                        .frame(width: 90, height: 90)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            VIDATheme.progressGradient(for: progress),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 90, height: 90)
                        .animation(.linear(duration: 0.9), value: progress)
                    VStack(spacing: 0) {
                        Text(mmss)
                            .font(.title3.monospacedDigit())
                        Text("reste")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Button("Arrêter") { stop() }
                    .tint(.red)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
        .containerBackground(VIDATheme.emeraldSoft, for: .navigation)
        .onDisappear { stop() }
    }

    private var progress: Double {
        let total = Double(selectedDuration.rawValue)
        return total > 0 ? 1 - Double(remaining) / total : 0
    }

    private var mmss: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func start() {
        remaining = selectedDuration.rawValue
        isRunning = true
        WKInterfaceDevice.current().play(.start)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if remaining <= 1 {
                    finish()
                } else {
                    remaining -= 1
                    if remaining % 60 == 0 {
                        WKInterfaceDevice.current().play(.click)
                    }
                }
            }
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remaining = 0
        WKInterfaceDevice.current().play(.success)
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remaining = 0
    }
}

#Preview("Idle") {
    RitualTimerView()
}
