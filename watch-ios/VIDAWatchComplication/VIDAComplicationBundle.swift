//
//  VIDAComplicationBundle.swift
//  VIDAWatchComplication — P8-F4
//
//  Bundle WidgetKit enregistrant 2 complications : Streak (4 familles) et
//  Steps (3 familles). Donnees alimentees via App Group UserDefaults ecrit
//  par l'app VIDAWatch apres chaque refresh.
//

import WidgetKit
import SwiftUI

@main
struct VIDAComplicationBundle: WidgetBundle {
    var body: some Widget {
        StreakComplication()
        StepsComplication()
    }
}
