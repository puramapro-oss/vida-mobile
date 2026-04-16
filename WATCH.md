# VIDA Watch — watchOS + Wear OS

VIDA est santé/bien-être → P8 Watch **OBLIGATOIRE** selon CLAUDE.md V7.

## watchOS (Apple Watch)

**Stack** : WatchKit + SwiftUI · iOS companion (même bundle `dev.purama.vida`) · HealthKit · ClockKit · WatchConnectivity

**Features**
- Dashboard circles : XP, Graines, Streak, Wallet (progress rings animés)
- Streak 🔥 avec compteur jours consécutifs
- Affirmation du jour (scroll Digital Crown)
- Respiration 4-7-8 guidée (haptics + cercle qui gonfle)
- Rappel rituel dimanche (notification APNs + complication)
- Check-in mission rapide (photo depuis iPhone push notif)
- Sync bidirectionnelle montre ↔ iPhone ↔ Supabase

**Adaptatif** : 38 mm → 49 mm Ultra (Series 4 through 10 + Ultra 1/2)

**Setup**
1. Ouvrir projet iOS Xcode (après `expo prebuild`)
2. File → New → Target → Watch App → "VIDA Watch"
3. Cocher "Include Complication"
4. Info.plist : `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`
5. Entitlements : HealthKit
6. WatchConnectivity session.sendMessage avec `supabase.auth.session.access_token`

**Fichiers à créer** (dans Xcode après prebuild)
- `vida Watch App/VIDAWatchApp.swift` — @main
- `vida Watch App/ContentView.swift` — TabView 4 tabs
- `vida Watch App/Views/HomeView.swift` — cercles progression
- `vida Watch App/Views/BreatheView.swift` — 4-7-8 animation
- `vida Watch App/Views/StreakView.swift` — jours consécutifs
- `vida Watch App/Complications/XPComplication.swift` — cadran
- `vida Watch App/HealthKit/HealthStore.swift` — pas/cardiaque/calories

## Wear OS (Samsung, Pixel, Fossil, OnePlus)

**Stack** : Jetpack Compose + Wear Compose · Android companion (même package `dev.purama.vida`) · Health Services API · Tiles

**Features** : identiques watchOS, adaptés Wear

**Setup**
1. Ouvrir projet Android Studio (après `expo prebuild`)
2. New Module → Wear OS → "VIDA Wear"
3. AndroidManifest.xml : `android.permission.BODY_SENSORS`, `android.permission.ACTIVITY_RECOGNITION`
4. DataClient pour sync phone ↔ watch

**Fichiers à créer** (dans Android Studio après prebuild)
- `wear/src/main/java/dev/purama/vida/MainActivity.kt`
- `wear/src/main/java/dev/purama/vida/ui/Home.kt` — CircularProgressIndicator XP/Graines/Streak
- `wear/src/main/java/dev/purama/vida/ui/Breathe.kt` — animation respiration
- `wear/src/main/java/dev/purama/vida/tiles/XPTile.kt` — Tile
- `wear/src/main/java/dev/purama/vida/health/HealthServices.kt`

## Deploy

- watchOS : même App Store Connect listing que iOS → `eas submit --platform ios` inclut la Watch App
- Wear OS : même Play Console listing que Android → `eas submit --platform android` inclut le Wear module

## Statut ici

Scaffolding documentation + specs créés. L'**implémentation native Swift/Kotlin nécessite Xcode (macOS) + Android Studio** ouverts manuellement — impossible depuis CLI seule car builds nécessitent simulateurs + provisioning profiles Apple Team ID (`APPLE_TEAM_ID=___à_remplir___` dans CLAUDE.md).

**Action Tissma requise** :
1. Acheter Apple Developer 99€/an → récupérer Team ID
2. `expo prebuild` pour générer `ios/` + `android/`
3. Ouvrir `ios/vida.xcworkspace` → suivre la section watchOS ci-dessus
4. Ouvrir `android/` dans Android Studio → suivre la section Wear OS
5. `eas build --profile production --platform all`
