# iOS Code Review Remediation, Battery Optimization & Web Simulator Parity

This plan addresses the bugs, cross-target state gaps, memory/storage leaks, and battery drain issues identified during the iOS 17.0+ code review, while mirroring applicable improvements to the Web Simulator and expanding the automated unit test suite.

### User Review & Critical Decisions

> [!IMPORTANT]
> All four optimization categories and behavioral choices have been confirmed and are incorporated into this plan without altering existing UI labels, icons, colors, or layout positions.

- **Confirmed Decision 1 (Scope)**: Include all four fix categories:
  1. Emergency outage persistence and synchronization across Main App, Widget Extension, and Notification Scheduler.
  2. Battery optimization for the 1-second foreground timer, status pulse animation, and 24-hour donations cache.
  3. Static caching of `Calendar` and `NSRegularExpression` instances plus bounded memory and `UserDefaults` caches.
  4. Automatic midnight day-rollover slot reloading and `BGAppRefreshTask` rescheduling when refresh interval settings change.
- **Confirmed Decision 2 (Foreground Timer Behavior)**: Pause 1-second countdown ticks whenever the user is not viewing the Main screen (such as when viewing Settings, About, or the mini-game), and resume immediately upon returning to the Main screen.
- **Confirmed Decision 3 (Web Simulator Parity & Testing)**: Mirror applicable logic improvements (midnight day-rollover handling, foreground tab-aware timer gating, and bounded cache hygiene) in the Web Simulator and verify all fixes with unit tests on every build.

---

### 1. Overview & Core Concept

- **What It Does**: Eliminates state desynchronization between the iOS app, WidgetKit extension, and local notification scheduler during emergency outages; reduces CPU wakeups, CoreAnimation render-loop drain, and redundant network calls; and eliminates repeated object allocations and unbounded cache growth.
- **Target Audience / Persona**: Users relying on the iOS app and Home Screen / Lock Screen widgets during power outages when battery conservation and accurate countdown/notification timing are critical.
- **Key Value**: Lower battery consumption in both foreground and background operation, zero stale schedules across midnight rollovers, and 100% consistent emergency outage state across the main screen, widgets, and pre-warning alerts.

---

### 2. User Experience & Visual Design

- **Key User Flows**:
  1. **Emergency Outage Continuity**: When an emergency outage is active for the user's house, closing and reopening the app, viewing the Home Screen widget, or receiving a pre-warning notification reflects the exact same overlapped emergency outage window.
  2. **Tab Switching & Mini-Game Battery Savings**: Switching from the Main screen to Settings, About, or Zhytomyr Roulette pauses the 1Hz countdown ticker and status-dot pulse animation; returning to the Main screen immediately recalculates the current Kyiv time and resumes the countdown without visual lag.
  3. **Seamless Midnight Transition**: If the app remains open past `00:00` Kyiv time, tomorrow's cached schedule automatically promotes to today's schedule without requiring a manual refresh.
- **Visual Identity & Theme**:
  - Preserves 100% of existing UI text, icons, colors, layout positions, and typography across both the iOS views and the 393x852 Web Simulator.
- **Interactive Feedback & Motion**:
  - The status indicator pulse animation runs only when a valid queue or active outage is displayed on the Main screen and pauses when the queue is unselected or when another tab is active.

---

### 3. Key Product Decisions & Trade-Offs

- **Decision 1: Tab-Aware & State-Aware Foreground Ticker**
  - *Chosen Approach*: Gate the 1-second foreground ticker so it ticks at 1Hz only when `scenePhase == .active`, the Main screen tab is selected (`selectedPage == 0`), the mini-game overlay is closed (`!isRouletteOpen`), and an active countdown is displayed (`countdownText != "--:--:--"`). Otherwise sleep in low-power intervals or pause until state changes.
  - *Why*: Mutating root `@State` every second while the user interacts with Settings pickers, reads About links, or plays the mini-game causes unnecessary SwiftUI view-tree diffs and GPU frame renders.
  - *Alternatives Considered*: Keeping a global 1Hz timer running across all tabs, which wastes battery without visible benefit on non-countdown screens.
- **Decision 2: Shared App Group Persistence for Emergency Outages & HTTP Conditional Caching**
  - *Chosen Approach*: Persist `active_emergency_outage_start`, `active_emergency_outage_restore`, `ztoe_last_etag`, and `ztoe_last_html_cache` in the shared App Group `UserDefaults` (`group.ua.blackout.prewarning`) with thread-safe lock protection.
  - *Why*: WidgetKit timelines and `BGAppRefreshTask` callbacks execute in separate processes or fresh app lifecycles; persisting emergency outage bounds and ETag headers in the App Group ensures widgets always display emergency outages and background refreshes save cellular data and radio energy via HTTP `304 Not Modified`.
  - *Alternatives Considered*: Process-local static variables, which reset whenever iOS suspends or terminates the process.
- **Decision 3: Pre-Compiled Regexes, Cached Kyiv Calendar & Bounded Caches**
  - *Chosen Approach*: Convert `KyivZone.calendar` from a computed property into a cached static constant, pre-compile all HTML table/row/cell/date `NSRegularExpression` patterns once as static properties, cap `AlertRegistry` to the 100 most recent entries (pruning expired dates), and cap `detailedIntervalsCache` to 64 entries.
  - *Why*: Avoids allocating `Calendar`/`Locale` structs multiple times per second and eliminates ~72 redundant regex compilations on every schedule refresh.

---

### 4. Technical Architecture & Data Strategy *(Technical Reference)*

- **Architecture & Component Diagram**:

```
┌────────────────────────────────────────────────────────────────────────────┐
│                   App Group Storage (group.ua.blackout.prewarning)         │
│  • Queue, Address & Emergency Outage Bounds (Start / Restore)              │
│  • Today & Tomorrow Slot Bitmaps + ETag / HTML Cache                       │
│  • Bounded Alert Registry (Max 100 Recent Slot IDs)                        │
└───────────────┬──────────────────────────────┬─────────────────────────────┘
                │                              │
                ▼                              ▼
┌───────────────────────────────────┐  ┌─────────────────────────────────────┐
│   Shared Domain & Parser Engine   │  │     WidgetKit & AppIntents          │
│  • Static KyivZone Calendar       │  │  • BlackoutWidgetProvider           │
│  • Pre-compiled Regex HTML Parser │  │    (Applies Emergency Outage)       │
│  • Bounded Interval Cache (<=64)  │  │  • RefreshScheduleIntent            │
│  • Emergency Outage Slot Merger   │  │    (Fetches + Syncs Alarms +        │
└───────────────┬───────────────────┘  │     Reloads Widget Timelines)       │
                │                      └─────────────────────────────────────┘
                ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                Foreground Navigation & Background Sync                     │
│  • Tab-Aware Ticker: 1Hz only on active Main Screen with live countdown    │
│  • Midnight Rollover Detector: Auto-promotes Tomorrow -> Today at 00:00    │
│  • Settings Screen: Reschedules BGAppRefreshTask when interval changes     │
│  • Donations Repository: Respects 24-hour TTL cache on app launch          │
└────────────────────────────────────────────────────────────────────────────┘
```

- **Data Model & State**:
  - **UserSettings Persistence**: Stores `activeEmergencyOutageStart` and `activeEmergencyOutageRestore` alongside `selectedRem`, `selectedSettlement`, `selectedStreet`, and `selectedHouse` in App Group `UserDefaults` and clears them cleanly on `resetDefaults()`.
  - **Bounded Caches**:
    - `ScheduleRepository.detailedIntervalsCache`: Evicts oldest entries when count exceeds 64.
    - `AlertRegistry`: Prunes entries from past dates and caps stored identifiers at 100 entries, matching the Web Simulator's storage hygiene.
- **Interactive Component & State Mapping**:
  - **Main Screen Navigation**: Passes `emergencyOutageStartTime` and `emergencyOutageRestoreTime` from `UserSettings` into `MainScreen` and applies `applyEmergencyOutageToSlots` inside `reloadLocalSlots()` and `NotificationScheduler.syncAlarms()` so UI, widgets, and notifications are 100% synchronized.
  - **Midnight Rollover**: Tracks the current Kyiv date string (`YYYY-MM-DD`) in the foreground ticker (both iOS and Web Simulator) and automatically reloads/promotes schedules when the date transitions across `00:00`.
  - **Background Refresh Rescheduling**: Invokes `BackgroundSyncManager.shared.schedulePeriodicWork()` whenever `refreshIntervalMinutes` is updated in Settings, and invokes `NotificationScheduler.shared.syncAlarms()` inside `RefreshScheduleIntent.perform()`.
  - **Donations Daily Cache**: Calls `getDonationsWithDailyRefresh(forceRefresh: false)` on normal app launch so the 24-hour cache is respected instead of forcing a network download on every launch.
