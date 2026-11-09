# Android Port Update Specification Plan (`ANDROID_UPDATE_SPEC.md`)

This plan outlines the creation of a comprehensive, self-contained engineering specification document (`ANDROID_UPDATE_SPEC.md`) in the repository root so that all features, UI/UX refinements, parsing algorithms, emergency outage workflows, and battery/performance optimizations developed after `v1.3.3` can be reproduced 1:1 in the Android application (`Android-ZTBlackoutPreWarning`).

## User Review & Critical Decisions

> [!IMPORTANT]
> All options from the clarification phase have been included per your confirmation:

- **Confirmed Decision 1 (Target File)**: Create `ANDROID_UPDATE_SPEC.md` in the repository root (`/ANDROID_UPDATE_SPEC.md`).
- **Confirmed Decision 2 (Document Scope — All Categories Included)**:
  1. All UI, UX, and localization changes since `v1.3.3`
  2. ZTOE address lookup, no-queue house handling, and emergency outage (`Аварійне відключення`) algorithms
  3. Battery, caching, midnight rollover, and widget/notification synchronization logic
  4. Native Android (Kotlin, Jetpack Compose, Glance AppWidget, WorkManager, AlarmManager, SharedPreferences) mapping guide & unit test checklist

---

## 1. Overview & Core Concept

- **What It Delivers**: A complete technical specification and reproduction blueprint in `ANDROID_UPDATE_SPEC.md` covering every enhancement, bug fix, and architectural improvement introduced since the initial `v1.3.3` baseline.
- **Target Audience / Use Case**: Engineers or automated coding agents updating the Android codebase (`https://github.com/IgorZaharov/Android-ZTBlackoutPreWarning`) to achieve 100% functional, visual, and algorithmic parity with the current iOS 17.0+ and Web Simulator reference implementation.
- **Key Value**: Eliminates ambiguity by providing exact data structures, HTML/JSON parsing rules, state transition tables, UI layout specifications, exact bilingual (`uk`/`en`) strings, and Kotlin/Compose equivalents.

---

## 2. User Experience & Visual Design Covered in Specification

- **First Application Launch (Unset Queue Zero-State)**:
  - Default queue on fresh install or full app reset is empty (`""`), and default language is `"system"` (`Auto`).
  - All background UI elements on the Main screen and the bottom navigation dock are dimmed (`opacity: 0.15`, `brightness: 50%`) and disabled (`pointer-events: none` / `.disabled(true)`).
  - Full-screen centered overlay (`first-start-select-queue-overlay`) displays:
    1. Enlarged centered primary CTA button (`min-width: 260dp`, `#FF5E3A` background):
       - UK: `"Виберіть чергу"` / Subtitle: `"Житомиробленерго (ZTOE)"`
       - EN: `"Select queue"` / Subtitle: `"Житомиробленерго (ZTOE)"`
    2. Directly below the button, a 3-segment language selector (`Auto` = `"system"`, `English` = `"en"`, `Українська` = `"uk"`) that immediately switches the default UI language.
  - Pressing `"Виберіть чергу"` / `"Select queue"` navigates to Settings and automatically opens the full-screen `"?"` Queue Lookup & Help modal.
  - Once a queue (or no-queue address) is selected and applied for the first time, the app automatically navigates back to the Main window.

- **Full-Screen `"?"` Address Lookup & Manual Search Modal in Settings**:
  - Enlarged `"?"` button (`40x40dp`, `#FF5E3A`) in the Queue Selection card header.
  - Opens a full-screen modal (`#141A29`) structured in strict top-to-bottom order:
    1. **Search by Address (`"Пошук черги за адресою"` / `"Find Queue by Address"`)**:
       - Expanded internal container with `2dp` border (`border-white/25`) and enlarged dropdown controls (`text-base font-bold`, `px-4 py-3.5`).
       - Stacked vertical dropdowns:
         - **РЕМ (`District (РЕМ)`)**: Default `"Житомирський РЕМ"`.
         - **Населений пункт (`City / Settlement`)**: Default `"м. Житомир"`.
         - **Вулиця (`Street`)**: Unselected by default on first launch (`""` -> `"Оберіть вулицю"` / `"Select street"`).
         - **Будинок (`House Number`)**: Unselected by default (`""` -> `"Оберіть будинок"` / `"Select house"`).
       - Persists and restores the user's selected address (`remId`, `settlementId`, `streetId`, `house`) whenever re-entering Settings or reopening the `"?"` modal.
    2. **Manual Search Header (`"Пошук вручну"` / `"Manual search"`)**.
    3. **Numbered Instructions `1–4`** (with no trailing period after the URL in Step 1).

- **Main Window Display Rules (Selected Address, No-Queue Houses & Emergency Outages)**:
  - **Address Word-Wrapping**: Formats saved addresses so a line break (`\n`) is inserted immediately after the city/settlement name (`"Житомирський РЕМ, м. Житомир,\nвул. Київська, буд. 77"`), placing street and house number on the second line.
  - **No-Queue House State** (e.g., `вул. Київська, буд. 104` returning `"В цей час не вимикається, за винятком випадків аварійних відключень"`):
    - Top header queue title is hidden (empty placeholder).
    - Full unshortened ZTOE status message is displayed in a standard card bar above the countdown card.
    - Main countdown displays `"--:--:--"` (with no `"--:-- - --:--"` line above it).
    - 24-hour Drum Chart renders all 24 hour columns (`00..23`) with light internal squares (`POWER_ON` visual state) rather than an unclear/hidden chart.
  - **Active Emergency Outage (`"Аварійне відключення"` / `"Emergency Outage"`)**:
    - Dedicated orange/red alert banner on the Main screen showing start time (`Початок`) and estimated restoration time (`Орієнтовне відновлення`).
    - Emergency outage time ranges take priority over and merge with scheduled ZTOE outages across:
      1. Main countdown timer (`calculateOutageCountdown`)
      2. 24-hour Drum Chart half-hour slots (`getChartHalfHourBlocks`)
      3. Today & Tomorrow blackout interval lists (`getBlackoutIntervals`)
      4. Home screen Widgets (Small & Medium/Large)
      5. Pre-warning & state-change Notifications
  - **Today / Tomorrow Blackout Hours List**:
    - Headers: `"Години відключень на сьогодні:"` / `"Blackout hours for today:"` on Today tab, and `"Години відключень на завтра:"` / `"Blackout hours for tomorrow:"` on Tomorrow tab.
    - Fixed `20x20dp` indicator slot before every timeslot so text is 100% horizontally aligned whether or not emergency outages exist:
      - Emergency interval (`isEmergency == true`): `"!"` inside a `20x20dp` circle (`#FF5E3A`).
      - Regular interval (`isEmergency == false`): centered `10x10dp` `#FF5E3A` dot inside the same `20x20dp` slot.

---

## 3. Key Product Decisions & Algorithmic Safeguards

- **Decision 1: Preserve User-Selected Address Queue on Live ZTOE Refresh**
  - *Chosen Approach*: When a user selects an address that already has a defined queue in the address lookup directory (e.g., `вул. Київська, буд. 77` -> Queue `5.2`), periodic or initial `checkAddressOnZtoeWebsite` refreshes must NEVER overwrite `5.2` with a conflicting commercial/secondary row (such as `3.2`) from the live HTML table.
  - *Why*: Multi-building or mixed residential/commercial records on ZTOE can list multiple queues for the same building number. Overwriting the user's selected queue caused the `5.2 -> 3.2` bug. Live queue assignment only updates `settings.queue` when the user's house previously had **no queue** (`queue == ""`) and later receives a queue on ZTOE.

- **Decision 2: Battery, Performance & Background Sync Optimizations**
  - *Chosen Approach*:
    1. Pause the 1-second foreground countdown ticker whenever the app is backgrounded, on Settings/About screens, or inside the `Житомирська Рулетка` mini-game.
    2. Cache `TimeZone("Europe/Kyiv")` / `Calendar` and pre-compile all HTML/table regular expressions as static singletons.
    3. Use HTTP `ETag` / `If-None-Match` (`304 Not Modified`) caching on schedule fetches and bound in-memory/SharedPreferences caches (`MAX_INTERVAL_CACHE_ENTRIES = 64`, `MAX_STORED_ENTRIES = 100`).
    4. Handle midnight rollover (`00:00` `Europe/Kyiv`) by automatically promoting cached `tomorrow` slots into `today` slots when offline.
    5. Reschedule periodic background refresh (`WorkManager` / `BGAppRefreshTask`) whenever `refreshIntervalMinutes` changes in Settings.
    6. Refresh `donations.json` at most once every 24 hours (`86,400,000 ms`).

---

## 4. Technical Architecture & Document Structure

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        ANDROID_UPDATE_SPEC.md Structure                      │
├──────────────────────────────────────────────────────────────────────────────┤
│  1. Executive Summary & Delta Overview (v1.3.3 -> Current)                   │
│  2. First-Launch UX, Language Switch & Navigation Lock Flow                  │
│  3. Full-Screen "?" Address Lookup Modal & Persistent Address State          │
│  4. ZTOE Address Lookup & Live Queue Re-Check Algorithm (5.2 -> 3.2 Fix)     │
│  5. No-Queue House Display Rules ("--:--:--", Light Drum Chart, Full Text)   │
│  6. Emergency Outages ("Аварійне відключення") Detection, Overlap & Alerts   │
│  7. Today/Tomorrow List Alignment & "!" Emergency Circle Indicator           │
│  8. Widget Synchronization (Main Counter + Emergency Outage Parity)          │
│  9. Battery, Caching, Midnight Rollover & Background Work Optimizations      │
│ 10. Android Implementation Mapping (Kotlin / Compose / Glance / WorkManager) │
│ 11. Complete Verification & Unit Test Checklist                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Interactive Component & State Mapping to Include in `ANDROID_UPDATE_SPEC.md`
- **Data Models (`UserSettings`, `EmergencyOutageInfo`, `AddressQuery`, `BlackoutSlot`, `BlackoutInterval`)**: Complete field definitions, default values, and `SharedPreferences` keys.
- **Algorithms with Step-by-Step Pseudocode & Kotlin Snippets**:
  - `parseZtoeAddressLookupTableHtml` & `checkAddressOnZtoeWebsite` (including `Windows-1251` / `UTF-8` decoding and no-queue vs. existing-queue resolution).
  - `matchEmergencyOutageFromAccidentsJson` & `parseZtoeEmergencyOutagesTableHtml` (`pw_accidents` JSON + HTML table fallback, house token matching with Cyrillic suffixes).
  - `applyEmergencyOutageToSchedule` / `applyEmergencyOutageToSlots` (slot-level override, midnight-spanning outages, `isEmergency` propagation into `getBlackoutIntervals` and `calculateOutageCountdown`).
  - `checkAndTriggerEmergencyOutageAlert` (state-transition deduplication: fire once on detection, no repeat while active, fire once on restoration, respect `notificationsEnabled`).
- **Unit Test Coverage**: Add verification in `/tests/unit.test.ts` confirming `/ANDROID_UPDATE_SPEC.md` exists and documents all required sections and algorithms.
