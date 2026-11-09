# Світло в Житомирі — iOS Port Handover & Architecture Guide (`iOS-ZTPreBlackoutNotification`)

## 1. Executive Summary & Parity Guarantee

**Світло в Житомирі** (`iOS-ZTPreBlackoutNotification`, `v1.3.3`) is the official native **iOS 17.0+** port of [`Android-ZTBlackoutPreWarning`](https://github.com/IgorZaharov/Android-ZTBlackoutPreWarning). It monitors hourly power outage schedules published by **JSC "Zhytomyroblenergo" (ZTOE)** at `https://www.ztoe.com.ua/unhooking-search.php` across all 12 consumer sub-queues (`1.1`, `1.2`, `2.1`, `2.2`, `3.1`, `3.2`, `4.1`, `4.2`, `5.1`, `5.2`, `6.1`, `6.2`) at **30-minute (48 half-hour slot) resolution**.

This repository contains two synchronized implementations with 100% parity in business logic, UI layout, colors, localization, icons, and automated unit tests:
1. **Native iOS 17.0+ Application (`/ios`)**: Written in Swift 5.10 with SwiftUI, WidgetKit (`systemSmall` & `systemMedium`), interactive `AppIntents` (`RefreshScheduleIntent`, `ToggleAlertsIntent`), `BackgroundTasks` (`BGAppRefreshTask`), `UserNotifications` (`UNCalendarNotificationTrigger`), and `XCTest` (`ZtoeParserTests.swift`).
2. **Interactive Web Simulator & Developer Workbench (`/src`)**: Written in React 19, TypeScript, and Tailwind CSS (Vite). Provides a live 16:10 scrollable smartphone emulator, interactive WidgetKit simulator, Swift & Kotlin source code explorer, Xcode / IPA build guide, and App Store / Play Store promotional gallery.

---

## 2. Native iOS Architecture & Subsystem Mapping (`/ios`)

| Android Subsystem (`/android`) | iOS Port Equivalent (`/ios`) | Parity & Implementation Details |
|---|---|---|
| `KyivZone.kt` | `ios/Shared/KyivZone.swift` | Resolves `TimeZone(identifier: "Europe/Kyiv")` with fallback to `"Europe/Kiev"` and `TimeZone.current`. |
| `Models.kt` | `ios/Shared/Models.swift` | Identical data structures, `advanceNoticeMinutes = 15`, `refreshIntervalMinutes = 30`, `ALL_QUEUES` (`1.1`–`6.2`), and Roulette constants (`MAX_ROULETTE_SCORE = 9_999_999`, `SCORE_SHUFFLE_THRESHOLD = 999`). |
| `AppStrings.kt` | `ios/Shared/AppStrings.swift` | 100% identical Ukrainian (`uk`) and English (`en`) strings, 4-step Queue Help text, `"Зрозуміло"`, `"СВІТЛО Є"` / `"СВІТЛА НЕМАЄ"`, `"Графіки не діють"` / `"Outages unclear"`, `"Charity / Благодійність і Пожертви"`, and `"Світло в Житомирі на Github"`. |
| `ZtoeParser.kt` | `ios/Shared/ZtoeParser.swift` | Validates URL against `valid-urls.json`, decodes Windows-1251 via `CFStringConvertEncodingToNSStringEncoding`, filters leaf `<table>` elements, matches exact `(day, month, year)` dates in top 2 rows, extracts 48 half-hour slots across all 12 queues, and sets Unclear state on failure. |
| `ScheduleRepository.kt` | `ios/Shared/ScheduleRepository.swift` | Persists today/tomorrow slots + per-queue ISO dates in shared App Group `UserDefaults(suiteName: "group.ua.blackout.prewarning")`, merges contiguous 30-min `POWER_OFF` slots into `DetailedInterval` blocks, and calculates real-time countdowns (including cross-midnight and tomorrow 1st blackout fallback). |
| `SettingsRepository.kt` | `ios/Shared/SettingsRepository.swift` | Persists settings in shared App Group `UserDefaults` with type-safe readers (`readSafeInt`, `readSafeLong`, `readSafeBoolean`, `readSafeString`) and saves/restores `prev_sound_enabled` & `prev_vibration_enabled` when toggling Master Notifications. |
| `DonationsRepository.kt` | `ios/Shared/DonationsRepository.swift` | Syncs `donations.json` on startup and every 24 hours (`86_400_000` ms) with `ETag` conditional caching and two-part Ukrainian TLD (`in.ua`, `com.ua`) favicon resolution. |
| `AlarmScheduler.kt` & `NotificationHelper.kt` | `ios/ZTPreBlackout/Notifications/NotificationScheduler.swift` & `AlertRegistry.swift` | Schedules one `UNCalendarNotificationTrigger` per contiguous blackout block (`block_${today}_${startStr}_${endStr}_Q${queue}`), sweeps stale notifications across all 12 queues, protects in-flight windows, and resets future slots on backward clock changes (`NSSystemClockDidChange`). |
| `ScheduleSyncWorker.kt` | `ios/ZTPreBlackout/Worker/BackgroundSyncManager.swift` | Registers `BGAppRefreshTask` (`ua.blackout.prewarning.sync`) at `max(15, settings.refreshIntervalMinutes)` minutes and reloads WidgetKit timelines on completion. |
| `BlackoutGlanceWidget.kt` | `ios/BlackoutWidgetExtension/BlackoutWidget.swift` & `WidgetIntents.swift` | Renders `systemSmall` (2x1) and `systemMedium` (3x2) widgets with 20% transparent dark navy background (`0xCC141A29`), localized `HHг. MMхв.` / `HHhr. MMm.` countdown without seconds, interactive Refresh & Bell `AppIntent` buttons, and the `720x132` **САЗУ-ИТ** 24h bitmap. |
| `BlackoutAppNavigation.kt`, `MainScreen.kt`, `SettingsScreen.kt`, `AboutScreen.kt`, `ZhytomyrRouletteScreen.kt` | `ios/ZTPreBlackout/UI/*.swift` | Full SwiftUI views with `TabView(.page)` horizontal swiping, `scenePhase == .active` 1-second foreground ticker (throttled to 15s when stopped), САЗУ-ИТ `TimelineBar`, and the complete **"Житомирська Рулетка"** mini-game with 9 foil textures, 10 MP3 audio files, Power Shop, Milestone Progress Bar, Share Card, and AntiCheat. |

---

## 3. Building, Testing & Installing the iOS App

### 3.1 Running the Web Simulator & Automated Unit Tests
```bash
npm install
npm test          # Runs Unit Tests A, B, C, and D (including iOS Swift parity checks)
npm run dev       # Starts Vite dev server on http://localhost:3000
npm run build     # Builds production web bundle into dist/
```

### 3.2 Generating the Xcode Project & Building Locally on macOS
Requires **macOS 14+** with **Xcode 15.4+** and **XcodeGen**:
```bash
cd ios
brew install xcodegen
xcodegen generate
open iOS-ZTPreBlackoutNotification.xcodeproj
```
In Xcode:
1. Select the **ZTPreBlackout** scheme and your iPhone or iOS Simulator.
2. Under **Signing & Capabilities**, select your personal Apple ID Team (free Apple ID works for 7-day device sideloading, or paid Apple Developer Team for TestFlight / App Store).
3. Press **Cmd + R** to build and run on your iPhone, or **Cmd + U** to run `ZtoeParserTests.swift`.

### 3.3 Installing the Unsigned `.ipa` from GitHub Actions (No Mac Required)
Every push to `main` or `v*` tag triggers `.github/workflows/build-ipa.yml` on GitHub's `macos-14` cloud runner and produces `iOS-ZTPreBlackoutNotification-unsigned.ipa`:
1. Download `iOS-ZTPreBlackoutNotification-unsigned.ipa` from the **Actions -> Artifacts** tab (or **Releases** tab on `v*` tags) of `https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification`.
2. Install it onto your iPhone using **AltStore**, **SideStore**, **Sideloadly** (Windows / macOS with a free Apple ID), or **TrollStore** — each tool automatically signs the `.ipa` with your Apple ID during installation.
