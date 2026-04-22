//
//  ProgressRing.swift
//  VIDAWatch — P8-F3
//
//  Anneau de progression reutilisable (Dashboard + complications circulaires).
//

import SwiftUI

struct ProgressRing: View {
    let value: Double           // 0.0 ... 1.0
    let lineWidth: CGFloat
    let iconSystemName: String?

    init(value: Double, lineWidth: CGFloat = 6, iconSystemName: String? = nil) {
        self.value = max(0, min(1, value))
        self.lineWidth = lineWidth
        self.iconSystemName = iconSystemName
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    VIDATheme.progressGradient(for: value),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.6), value: value)
            if let iconSystemName {
                Image(systemName: iconSystemName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        ProgressRing(value: 0.3, iconSystemName: "figure.walk")
        ProgressRing(value: 0.7, iconSystemName: "heart.fill")
        ProgressRing(value: 1.0, iconSystemName: "flame.fill")
    }
    .frame(width: 180, height: 60)
}
