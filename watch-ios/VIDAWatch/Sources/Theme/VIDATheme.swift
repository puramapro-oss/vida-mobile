//
//  VIDATheme.swift
//  VIDAWatch — P8-F3
//
//  Couleurs + typo partagees par les 6 ecrans. Emerald VIDA (#10B981) est
//  deja dans AccentColor.colorset — on expose juste un alias semantique.
//

import SwiftUI

enum VIDATheme {
    static let emerald = Color(red: 0.063, green: 0.725, blue: 0.506)  // #10B981
    static let emeraldSoft = Color(red: 0.063, green: 0.725, blue: 0.506).opacity(0.18)
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)           // super-admin gold #FFD700
    static let warmOrange = Color(red: 0.98, green: 0.58, blue: 0.28)   // streak fire
    static let deepViolet = Color(red: 0.49, green: 0.23, blue: 0.93)   // #7C3AED accent

    static func progressGradient(for value: Double) -> LinearGradient {
        LinearGradient(
            colors: value >= 1.0
                ? [gold, warmOrange]
                : [emerald, deepViolet],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

/// WatchKit preview tailles officielles (mm → pixels logiques).
/// Series 4/5/6/SE : 40/44. Series 7/8/9/10 : 41/45. Ultra : 49.
enum WatchSize: String, CaseIterable {
    case s38 = "38mm"   // legacy, minimal support
    case s41 = "41mm"   // Series 7+
    case s45 = "45mm"   // Series 7+ large
    case s49 = "49mm"   // Ultra

    var width: CGFloat {
        switch self {
        case .s38: return 136
        case .s41: return 176
        case .s45: return 198
        case .s49: return 205
        }
    }
    var height: CGFloat {
        switch self {
        case .s38: return 170
        case .s41: return 215
        case .s45: return 242
        case .s49: return 251
        }
    }
    var size: CGSize { CGSize(width: width, height: height) }
}
