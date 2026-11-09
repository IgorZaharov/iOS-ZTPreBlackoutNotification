# Світло в Житомирі — iOS Port (`iOS-ZTPreBlackoutNotification`) Implementation Plan

A complete native iOS 17.0+ port (Swift 5.10, SwiftUI, WidgetKit, AppIntents, BackgroundTasks, UserNotifications, XCTest) and synchronized 5-tab Web Simulator & Developer Workbench with 100% feature, UI, color, text, icon, and unit-test parity with `Android-ZTBlackoutPreWarning` (`v1.3.3`).

## User Review & Critical Decisions

> [!IMPORTANT]
> The following architectural and product choices have been confirmed from your answers and the reference repository (`v1.3.3`).

- **Confirmed Decision 1 — Minimum Deployment Target (`iOS 17.0+`)**: Uses `WidgetKit` with `Button(intent:)` (`AppIntents`) so users can tap the round Refresh and Bell toggle buttons directly on the Small (`systemSmall`) and Medium (`systemMedium`) Home Screen widgets without launching the main app.
- **Confirmed Decision 2 — GitHub Actions macOS CI/CD Packaging**: Configures `.github/workflows/build-ipa.yml` on `macos-14` (Xcode 15.4+) to run both `npm test` and `xcodebuild test`, package an unsigned `.ipa` (compatible with Sideloadly, AltStore, and TrollStore), and optionally sign a distribution `.ipa` when Apple Developer certificate secrets (`BUILD_CERTIFICATE_BASE64`, `P12_PASSWORD`, `BUILD_PROVISION_PROFILE_BASE64`, `KEYCHAIN_PASSWORD`) are configured in the repository.
- **Confirmed Decision 3 — 5-Tab Web Simulator & Developer Workbench**: Preserves the complete 5-tab workbench (`Emulator` with 10:16 / 16:10 scrollable smartphone viewport, `WidgetKit Simulator`, `Swift Source Code Explorer`, `Xcode & IPA Build Guide` with downloadable `/public/iOS-ZTPreBlackoutNotification.zip`, and `App Store Promo Gallery`).

---

## 1. Overview & Core Concept

- **What It Does**: Monitors hourly power outage schedules published by JSC "Zhytomyroblenergo" (ZTOE) at `https://www.ztoe.com.ua/unhooking-search.php` across all 12 consumer sub-queues (`1.1` through `6.2`) at 30-minute (48 half-hour slot) resolution, delivers advance local notifications `N` minutes before each contiguous blackout interval, renders live Home Screen widgets with the classic **САЗУ-ИТ** 24-hour analog electricity meter faceplate, and includes the full bilingual **"Житомирська Рулетка"** scratch-off lottery mini-game with Power Shop, 9 foil textures, MP3 audio tracks, and Share Card export.
- **Target Audience / Persona**: Residents of Zhytomyr and Zhytomyr Oblast using iPhone (`iOS 17.0+`) who need reliable advance blackout alerts, low-battery background schedule syncing, glanceable Home Screen widgets, and offline resilience.
- **Key Value**: 100% behavioral, visual, color, and text parity with the Android release (`v1.3.3`), shared state between the main iOS app and WidgetKit extension via App Group (`group.ua.blackout.prewarning`), and automated dual-platform unit testing (`npm test` + `xcodebuild test`).

---

## 2. User Experience & Visual Design

- **Key User Flows**:
  1. **Main Schedule Window (`MainScreen.swift` / `MainView.tsx`)**: Displays queue header (`Черга X.Y`), master notification toggle switch (`#FF5E3A`), Hero status & countdown card (`До відключення залишилось` / `Найближчий період`, or grey `"Невідомо"` / `"Графіки не діють"` when the schedule site is unreachable or returns no queues), `Сьогодні` / `Завтра` tabs, the 24-hour САЗУ-ИТ analog timeline bar with red current-time needle, the list of blackout intervals for the selected day (`Години без світла на цей день:` / `Blackout hours for today:`), refresh status card, Facebook emergency outages link (`https://www.facebook.com/ztoe.com.ua`), and ZTOE schedule website link (`https://www.ztoe.com.ua/unhooking-search.php`).
  2. **Settings Window (`SettingsScreen.swift` / `SettingsView.tsx`)**: Provides the sub-queue picker (`1.1`–`6.2`) with the `?` 4-step help modal (with underlined clickable ZTOE link and `"Зрозуміло"` button), URL verification field against `valid-urls.json`, Advance Warning timer (`15` min default, `1..240` min), Site Refresh Interval (`30` min default, `15..240` min), Master Notifications / Sound / Haptic switches with previous-state memory, Language (`uk` / `en`) and Theme (`system` / `dark` / `light`) selectors, and Reset Defaults.
  3. **About Window & Charity Sync (`AboutScreen.swift` / `AboutView.tsx`)**: Displays app version (`1.3.3`), daily-refreshed `"Charity / Благодійність і Пожертви"` cards from `donations.json` with multi-source favicon caching, external project links (including `"Світло в Житомирі на Github"`), and the launch button for **"Житомирська Рулетка"** (`"Zhytomyr Roulette"`).
  4. **"Житомирська Рулетка" Mini-Game (`ZhytomyrRouletteScreen.swift` / `ZhytomyrRouletteModal.tsx`)**: Full-screen scratch-off mini-game featuring the Power Points milestone progress bar (`100`, `200`, `400`, `600`, `1000`), All-Time Best Score, Sound & Music switches, Power Shop (`Магазин Потужності` with `Additional X2`, `Neighbor's Socket`, `Second Chance`, `Fern Flower` 5% golden ticket, `Black Cat`, `Bat`, `Deposit Power Points` with FinMonitoring anti-cheat, `Daily Streak`, and `Perseverance`), 9 realistic lottery foil variations with randomized stain/wrinkle transforms, 20% scratch reveal threshold + wider red center medallion reveal, 2-second top-border card dealing animation, ticket position shuffling above score `999`, periodic brownout flicker + 10-second Game Blackout, MP3 background music & sound effects, and Share Card generation.
  5. **Home Screen Widgets (`BlackoutWidget.swift` / `WidgetSimulator.tsx`)**: Small (`systemSmall`, 2x1 equivalent) and Medium (`systemMedium`, 3x2 / 4x2 equivalent) widgets with 20% transparent dark navy background (`#141A29` at 80% opacity), `"СВІТЛО Є"` / `"СВІТЛА НЕМАЄ"` / `"Графіки не діють"` status, `HHг. MMхв.` / `HHhr. MMm.` countdown without seconds, interactive Refresh & Bell `AppIntent` buttons, and the 24-hour САЗУ-ИТ bitmap faceplate on the Medium widget.

- **Visual Identity & Theme (100% Parity with Android `v1.3.3`)**:
  - **Time-of-Day Ambient Palette (`TimeOfDayPalette.swift` / `timeOfDayPalette.ts`)**: Smoothly interpolates `primary` (60%), `secondary` (30%), `accent` (10%), and `supporting` channels across four Kyiv-time anchors:
    - *Morning (`05:00–11:00`, anchor `08:00`)*: `#F4F9F9`, `#4A7C59`, `#FFB085`, `#2C3E35`
    - *Day (`11:00–17:00`, anchor `14:00`)*: `#FFFFFF`, `#0A2540`, `#FFD166`, `#4682B4`
    - *Evening (`17:00–22:00`, anchor `19:30`)*: `#1A0B2E`, `#8B3A62`, `#FF6B6B`, `#FFE66D`
    - *Night (`22:00–05:00`, anchor `01:30`)*: `#0B0C10`, `#1F2833`, `#66FCF1`, `#C5C6C7`
  - **САЗУ-ИТ Meter & Status Tokens**:
    - Enamel bezel `#DFDDD0`, recessed drum slot `#4E514E`, crimson outage slot `#D62E26`, ivory power-on slot `#FCFBF7`, unclear grey slot `#9CA3AF`, current-time needle `#0B0B0A` / `#EF4444`.
    - Active switch & primary action accent `#FF5E3A`, widget background `rgba(20, 26, 41, 0.80)` (`0xCC141A29`).

---

## 3. Key Product Decisions & Trade-Offs

- **Decision 1 — Shared App Group Storage (`UserDefaults(suiteName: "group.ua.blackout.prewarning")`)**:
  - *Chosen Approach*: Both the main iOS app target and the `BlackoutWidgetExtension` target read and write schedule caches (`zt_schedule_cache_v1`) and user settings (`zt_user_settings_v1`) in a shared App Group container.
  - *Why*: Guarantees that changing the queue or toggling notifications in the app or directly on the Home Screen widget immediately synchronizes state across both surfaces via `WidgetCenter.shared.reloadAllTimelines()`.
- **Decision 2 — Pre-Warning Notifications & Clock-Change Resilience (`UNUserNotificationCenter`)**:
  - *Chosen Approach*: Schedules exact `UNCalendarNotificationTrigger` alerts in the `Europe/Kyiv` timezone (`TimeZone(identifier: "Europe/Kyiv") ?? TimeZone(identifier: "Europe/Kiev") ?? .current`) for each contiguous `DetailedInterval` (`block_${today}_${startStr}_${endStr}_Q${queue}`) at `blockStartTime - advanceNoticeMinutes`, removes all pending notifications from previous queues on every sync, and listens to `NSSystemClockDidChange` / `UIApplication.significantTimeChangeNotification` to re-verify and reschedule future alerts.
  - *Why*: Matches Android's `AlarmScheduler` + `AlarmReceiver` deduplication and clock-tamper safety while respecting iOS background execution rules without draining battery.
- **Decision 3 — XcodeGen (`ios/project.yml`) for Deterministic Xcode Project Generation**:
  - *Chosen Approach*: Maintain a declarative `ios/project.yml` spec alongside the full `.xcodeproj` so GitHub Actions macOS runners (`xcodegen generate && xcodebuild ...`) can compile both the main app and widget extension cleanly without manual Xcode GUI steps.
  - *Why*: Eliminates fragile `.pbxproj` merge conflicts and allows 1-command CI/CD builds on GitHub Actions.

---

## 4. Technical Architecture & Data Strategy

### Architecture & Component Diagram

```
+-----------------------------------------------------------------------------------+
|                   https://www.ztoe.com.ua/unhooking-search.php                    |
|            (Windows-1251 HTML tables with 48 half-hour cells per queue)           |
+-----------------------------------------+-----------------------------------------+
                                          |
                 HTTP GET (Accept-Encoding: gzip, If-None-Match / ETag)
                                          v
+-----------------------------------------------------------------------------------+
|                        ZtoeParser.swift / ztoeParser.ts                           |
|  1. Validates URL against valid-urls.json                                         |
|  2. Decodes Windows-1251 stream (CFStringConvertEncodingToNSStringEncoding)       |
|  3. Matches Today & Tomorrow leaf tables via exact (day, month, year) regex       |
|  4. Extracts all 12 queues in a single pass (48 slots/day, 30-min resolution)     |
|  5. Marks schedule as UNCLEAR if site is unreachable or 0 queues are extracted    |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|             ScheduleRepository.swift (App Group UserDefaults + Cache)             |
|  - Persists today & tomorrow slots + per-queue ISO dates (Europe/Kyiv)            |
|  - Merges contiguous 30-min POWER_OFF slots into DetailedIntervals                |
|  - Computes real-time countdown (Today -> Tomorrow 1st blackout -> "--:--:--")    |
+-------------------+---------------------+---------------------+-------------------+
                    |                     |                     |
                    v                     v                     v
      +-----------------------+ +-------------------+ +-----------------------+
      |      SwiftUI App      | | NotificationSched | |  WidgetKit Extension  |
      |  (Main / Settings /   | | & BGAppRefresh    | | (systemSmall & Medium)|
      |   About / Roulette)   | | - Sweeps all 12   | | - Renders САЗУ-ИТ     |
      | - ScenePhase-aware 1s | |   queues on sync  | |   24h CGContext image |
      |   foreground ticker   | | - UNCalendar      | | - HHг. MMхв. format   |
      | - TabView page swipe  | |   triggers 1x/blk | | - AppIntent buttons   |
      +-----------------------+ +-------------------+ +-----------------------+
```

### Step-by-Step Implementation Plan

1. **Step 1 — Port Core Domain, Scraper, Localization & Audio Assets (`/src` & `/public`)**:
   - Port all canonical data files (`valid-urls.json`, `donations.json`, `CHANGELOG.md`, `PRIVACY_POLICY.md`), 9 lottery ticket foil textures, App Store promo graphics, and the 10 MP3 audio files (`audio_main_game.mp3`, `audio_start_shop_2.mp3`, `audio_start_shop_gameover.mp3`, `sfx_2x_coin.mp3`, `sfx_cash_register.mp3`, `sfx_coin.mp3`, `sfx_flicker.mp3`, `sfx_lightbulb.mp3`, `sfx_scratch.mp3`, `sfx_shuffle.mp3`).
   - Implement `ztoeParser.ts`, `alertManager.ts`, `donationsService.ts`, `i18n.ts`, `timeOfDayPalette.ts`, `rouletteGame.ts`, `rouletteAudio.ts`, and `types.ts` with 100% parity with `v1.3.3` (including the Unclear schedule state when unreachable, FinMonitoring anti-cheat, X2 tickets, 10s Game Blackout, and all exact Ukrainian/English strings).

2. **Step 2 — Build Native iOS Swift / SwiftUI / WidgetKit Project (`/ios`)**:
   - Create `ios/project.yml` (XcodeGen specification) and native Swift sources:
     - `KyivZone.swift`, `Models.swift`, `AppStrings.swift`, `TimeOfDayPalette.swift`
     - `ZtoeParser.swift` (Windows-1251 decoding, exact date regex, 48-slot table extraction, ETag conditional caching)
     - `ScheduleRepository.swift`, `SettingsRepository.swift` (with master notification toggle sound/haptic memory), `DonationsRepository.swift`
     - `NotificationScheduler.swift`, `AlertRegistry.swift`, `BackgroundSyncManager.swift` (`BGAppRefreshTask` + `NSSystemClockDidChange` observer)
     - `BlackoutAppNavigation.swift` (`TabView(.page)` horizontal pager + `scenePhase == .active` 1-second ticker that throttles to 15s when stopped), `MainScreen.swift`, `TimelineBar.swift` (САЗУ-ИТ 24h counter), `SettingsScreen.swift`, `AboutScreen.swift`, `ZhytomyrRouletteScreen.swift`
     - `BlackoutWidgetExtension/BlackoutWidget.swift` & `WidgetIntents.swift` (`RefreshScheduleIntent`, `ToggleAlertsIntent`, `CoreGraphics` САЗУ-ИТ 24h renderer, `systemSmall` and `systemMedium` layouts with 20% transparency).
   - Create `ios/ZTPreBlackoutTests/ZtoeParserTests.swift` mirroring all JUnit assertions from `ZtoeParserTest.kt`.

3. **Step 3 — Build 5-Tab Web Simulator & iOS Developer Workbench (`/src/components`)**:
   - Implement `PhoneSimulator.tsx` (16:10 / 10:16 scrollable smartphone frame + test controls including Roulette `+100 Power Points`, `Set Power Points to 9999`, `Reset All Game Progress`), `MainView.tsx`, `SettingsView.tsx`, `AboutView.tsx`, `ZhytomyrRouletteModal.tsx`, `WidgetSimulator.tsx`, `CodeExplorer.tsx` (browsing native Swift files), `BuildAndDownloadView.tsx` (Xcode / Sideloadly / AltStore / TestFlight instructions + downloadable `iOS-ZTPreBlackoutNotification.zip`), and `PlayStoreGuide.tsx` (App Store Promo Gallery).

4. **Step 4 — Configure GitHub Actions CI/CD, Packaging Script & Automated Unit Tests**:
   - Create `scripts/generate_ios_project.cjs` to bundle `/ios` into `/public/iOS-ZTPreBlackoutNotification.zip`.
   - Create `.github/workflows/build-ipa.yml` on `macos-14` to run `npm test`, generate the Xcode project via `xcodegen`, run `xcodebuild test`, package `iOS-ZTPreBlackoutNotification-unsigned.ipa` (and signed `.ipa` if secrets are present), upload build artifacts, and publish GitHub Releases on `v*` tags.
   - Create `tests/unit.test.ts` verifying all critical invariants across both TypeScript and Swift source files, and run `npm test`, `compile_applet`, and `lint_applet`.

---

## 5. Steps Required From You (User Action Checklist)

1. **Approve This Plan**: Click **Proceed** in the plan review panel (or reply with any adjustments) so I can generate the full codebase, native `/ios` project, downloadable `.zip`, GitHub Actions workflow, and unit test suite.
2. **Create the GitHub Repository**: Create an empty public or private repository at `https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification`.
3. **Push or Export the Project to GitHub**:
   - Export directly from AI Studio to `IgorZaharov/iOS-ZTPreBlackoutNotification` (or download the project / `iOS-ZTPreBlackoutNotification.zip` and push to `main`).
4. **Enable GitHub Actions Write Permissions**:
   - In your new repository on GitHub, go to **Settings -> Actions -> General -> Workflow permissions**, select **Read and write permissions**, and click **Save** (this allows the workflow to automatically attach `.ipa` files to GitHub Releases and update the version badge in `README.md` when you push a `v*` tag).
5. **(Optional) Configure Apple Developer Signing Secrets for TestFlight / App Store**:
   - By default, GitHub Actions will automatically build an **unsigned `.ipa`** on every run (ready for **AltStore**, **SideStore**, **Sideloadly**, or **TrollStore** without a paid Apple Developer account).
   - If you later want GitHub Actions to also produce an Apple-signed `.ipa` for TestFlight or App Store Connect, add these 4 optional repository secrets under **Settings -> Secrets and variables -> Actions**:
     - `BUILD_CERTIFICATE_BASE64` (your `.p12` distribution certificate encoded in base64)
     - `P12_PASSWORD` (password for the `.p12` certificate)
     - `BUILD_PROVISION_PROFILE_BASE64` (your `.mobileprovision` profile encoded in base64)
     - `KEYCHAIN_PASSWORD` (any temporary string password for the CI runner keychain)
