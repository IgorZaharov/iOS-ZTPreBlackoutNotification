# v1.3.4 Parity Implementation Plan (From Android `IOS_HANDOVER.md` + Floating Main Window Blocks)

This plan brings both the native iOS 17.0+ port (`ios/`) and the Web Simulator (`src/`) into 100% parity with the `v1.3.4` changes implemented in `https://github.com/IgorZaharov/Android-ZTBlackoutPreWarning` (`IOS_HANDOVER.md`), and adds pronounced floating drop shadows to all blocks in the Main window.

## User Review & Critical Decisions

> [!IMPORTANT]
> Confirmed selections from Phase 1 clarification and plan revision feedback:

- **Confirmed Decision 1 (Full `v1.3.4` Feature Parity)**:
  1. **Independent Emergency Outage Notifications Switch (`emergencyNotificationsEnabled`)**: Separate Card 4b in Settings, independent of the regular notifications toggle.
  2. **Zero-Delay `"?"` Address Lookup (`all=1` Bulk Settlement House Indexing, Persistent Disk Cache & `50ms` Launch Prefetch)**: Pre-indexed 19 REMs, settlements, streets, and bulk settlement houses (`zt_address_index_cache_v1`) with separated street/house effects.
  3. **HTML Entity & Apostrophe Decoding (`decodeZtoeHtmlEntities`)**: Converts single- and double-escaped `&#039;`, `&amp;#039;`, `&#39;`, `&#x27;`, `&apos;`, `&rsquo;`, `&lsquo;` into `'`.
  4. **Symmetrical Main Screen Emergency Rows, `"?"` Modal Subtitle & `v1.3.4` Version Bump**: Space-between aligned Start/Estimated Restore timestamp rows on the Main Screen emergency banner, subtitle under `"Пошук черги за адресою"` in the `"?"` modal, and `v1.3.4` version strings across the project.
- **Confirmed Decision 2 (Floating Effect Shadows on Main Window Blocks)**:
  - Add deep, multi-layered floating drop shadows to every card/block on the Main window in both `MainView.tsx` (`shadow-[0_20px_50px_rgba(0,0,0,0.75),0_8px_20px_rgba(0,0,0,0.55)]`) and `MainScreen.swift` (`.shadow(color: Color.black.opacity(0.65), radius: 18, x: 0, y: 12)`), giving all Main window cards a tactile, elevated floating appearance above the ambient time-of-day background.
- **Confirmed Decision 3 (Repository Tracking)**: Keep the full workspace tracked in `.gitignore` so the AI Studio Web Simulator and native iOS source files remain synchronized.

---

## 1. Overview & Core Concept

- **What It Does**: Upgrades the application to `v1.3.4` with floating elevated Main window cards, an independent Emergency Outage Notifications switch (`Card 4b`), instant `0ms` address dropdowns powered by settlement-wide bulk house indexing (`all=1`) and background launch prefetching, clean Ukrainian apostrophe decoding (`'` instead of `&#039;`), and symmetrical Main Screen emergency outage rows.
- **Key Value**: Users never miss critical unplanned emergency outage alerts even if they mute regular daily schedule notifications, selecting any street or building across all 19 REMs in the `"?"` modal happens instantaneously without network lag or raw HTML character codes, and Main window blocks visually float with clear depth separation.

---

## 2. User Experience & Visual Design

- **Main Window — Floating Block Shadows**:
  - Every card block on the Main screen (Custom Status Message Bar, Active Emergency Outage Banner, Hero Countdown & Status Card, 24-Hour Drum Chart & Today/Tomorrow Schedule Card, Last Updated / Refresh Bar, Emergency Outages Facebook Card, and ZTOE Website Schedules Card) receives a rich floating drop shadow:
    - Web Simulator (`MainView.tsx`): `shadow-[0_20px_50px_rgba(0,0,0,0.75),0_8px_20px_rgba(0,0,0,0.55)]` paired with subtle top-edge specular highlight (`ring-1 ring-white/10`) for a crisp floating elevation effect.
    - iOS SwiftUI (`MainScreen.swift`): `.shadow(color: Color.black.opacity(0.65), radius: 18, x: 0, y: 12)` on every card block in the Main screen stack.

- **Settings Screen — Card 4b (Independent Emergency Outage Notifications Switch)**:
  - Placed as a standalone frosted-glass card (`#141A29` at `75%` opacity, `24pt` corner radius, `1pt` `white/15` border, `20pt` padding) directly below **Card 4 (Notifications)** and above **Card 5 (Language)**.
  - Always visible regardless of whether an emergency outage is active.
  - Left side: Leading Bell icon (`18pt`, `#9CA3AF`) + multi-line wrapped label:
    - UK: `"Сповіщення про аварійні відключення"`
    - EN: `"Emergency outage notifications"`
  - Right side: `#FF5E3A` pill toggle switch bound to `settings.emergencyNotificationsEnabled` (default `true`).
  - Turning OFF the regular `"Увімкнути сповіщення"` / `"Enable notifications"` switch in Settings, Main Screen, or Widget **never** turns off `emergencyNotificationsEnabled`.

- **Settings `"?"` Address Lookup Modal Subtitle & Instant Dropdowns**:
  - Inside the `2px` white-bordered Search by Address block (`data-testid="ztoe-address-lookup-section"`), directly below the `"Пошук черги за адресою"` / `"Find Queue by Address"` title, displays the subtitle:
    - UK: `"(Або закрийте це вікно та виберіть тільки чергу)"`
    - EN: `"(Or close this window and select directly)"`
  - Opening `"?"` immediately displays cached REMs, Settlements, Streets, and Houses (`0ms`) while triggering a background refresh (`forceRefresh = true`).
  - Separated street-loading and house-loading `useEffect`s ensure selecting a street never resets or re-fetches the street list.

- **Main Screen — Symmetrical Active Emergency Outage Banner (`Card 1c`)**:
  - Standalone floating frosted-glass card above the Hero Countdown Card.
  - Start and Estimated Restore rows use `space-between` layout (`flex items-center justify-between` / `HStack { Text(...) Spacer() Text(...) }`) with right-aligned `tabular-nums` / `.monospacedDigit()` timestamps:
    - Row 1: Left `"Початок:"` / `"Start:"` — Right `startTime`
    - Row 2: Left `"Орієнтовне відновлення:"` / `"Estimated restore:"` — Right `estimatedRestoreTime`
  - Entering the Main Screen immediately refreshes `now` so the countdown timer and 24-hour drum chart are up to the current second.

---

## 3. Key Product Decisions & Trade-Offs

- **Decision 1: Settlement-Wide Bulk House Indexing (`all=1`) + Persistent Disk Cache (`zt_address_index_cache_v1`)**
  - *Chosen Approach*: When fetching streets for a settlement (`rem_id`, `naspunkt_id`, `all=1`), parse both `<select name="vulica_id">` and the 7-column settlement-wide house table (`parseZtoeSettlementHousesTableHtml`) in a single pass using pre-compiled regexes, indexing all houses for every street in the settlement at once and persisting to `zt_address_index_cache_v1` off the main thread.
  - *Why*: Eliminates per-street network wait times (`~5s` on large cities like Zhytomyr) and makes House dropdown selection instantaneous (`0ms`).

- **Decision 2: Strict Separation of Regular vs. Emergency Notification Toggles**
  - *Chosen Approach*: `toggleMasterNotifications` only toggles `notificationsEnabled` (for scheduled daily blackouts), leaving `emergencyNotificationsEnabled` untouched. `checkAndTriggerEmergencyOutageAlert` checks `settings.emergencyNotificationsEnabled !== false` instead of `settings.notificationsEnabled` and fires on emergency start, restoration time update, or cancellation.
  - *Why*: Users who mute routine daily schedule reminders still want to be alerted if an unexpected emergency accident (`Аварійне відключення`) or change in restoration time occurs at their address.

---

## 4. Technical Architecture & Data Flow

```
┌───────────────────────────────────────────────────────────────────────────────────┐
│                         App Launch (+50ms Background Task)                        │
│        prefetchAddressIndexInBackground(siteUrl, savedAddressQuery)               │
└─────────────────────────────────────────┬─────────────────────────────────────────┘
                                          │ POST /unhooking-search.php (all=1)
                                          ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│            ztoeAddressLookup.ts & ZtoeAddressLookup.swift                         │
│  1. Windows-1251 decode + decodeZtoeHtmlEntities (&amp;#039; / &#039; -> ')       │
│  2. Parse 19 REMs, Settlements, Streets & 7-column Settlement Houses Table        │
│  3. Hydrate/Persist zt_address_index_cache_v1 asynchronously (cap: 2500 streets)  │
└───────────────────┬───────────────────────────────────────────┬───────────────────┘
                    │ 0ms Synchronous Cache Read                │ Live Check + Emergency
                    ▼                                           ▼
┌───────────────────────────────────────┐   ┌───────────────────────────────────────┐
│   Settings "?" Address Lookup Modal   │   │   Main Screen & AlertManager          │
│ - Subtitle under Search by Address    │   │ - Floating shadow on all Main blocks  │
│ - Separated Street & House effects    │   │ - Symmetrical emergency start/restore │
│ - Preserves canonical 5.2 queue       │   │ - Independent Card 4b emergency switch│
└───────────────────────────────────────┘   └───────────────────────────────────────┘
```

### Interactive Component & State Mapping
- **`UserSettings` (`types.ts`, `alertManager.ts`, `Models.swift`, `SettingsRepository.swift`)**:
  - Add `emergencyNotificationsEnabled: boolean` (default `true`, persisted under `"emergency_notifications_enabled"`).
  - Preserve `emergencyNotificationsEnabled` when `toggleMasterNotifications` is toggled OFF/ON; reset to `true` on `resetDefaults` / `resetAllAppDataToFirstLaunch`.
- **`ztoeAddressLookup.ts` & `ZtoeAddressLookup.swift`**:
  - Implement `decodeZtoeHtmlEntities(raw)` and apply in `stripHtmlTags`, cache hydration, and option parsing/rendering.
  - Implement `parseZtoeRemOptionsHtml`, `parseZtoeSettlementOptionsHtml`, `parseZtoeStreetOptionsHtml`, `parseZtoeSettlementHousesTableHtml` (7-column bulk table), `fetchRemsFromZtoe`, `fetchSettlementsForRem`, `fetchStreetsForSettlement`, `fetchHousesForStreet`, `prefetchAddressIndexInBackground`, and persistent `zt_address_index_cache_v1` storage while preserving canonical house queues (e.g. `вул. Київська, буд. 77` -> `5.2` and `буд. 104` -> `""` with full status text).
- **`MainView.tsx`, `SettingsView.tsx`, `AboutView.tsx`, `App.tsx`, `MainScreen.swift`, `SettingsScreen.swift`, `AboutScreen.swift`, `BlackoutAppNavigation.swift`**:
  - Apply floating drop shadows to all Main window blocks/cards in `MainView.tsx` and `MainScreen.swift`.
  - Render Card 4b (`emergencyNotificationsEnabled`), `"?"` modal subtitle, symmetrical `space-between` emergency start/restore rows, `50ms` launch prefetch, immediate `now` refresh on Main Screen entry, and `v1.3.4` version bump.
