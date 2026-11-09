import SwiftUI

public struct BlackoutAppNavigation: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var settings: UserSettings = SettingsRepository.shared.loadSettings()
    @State private var todaySlots: [BlackoutSlot] = []
    @State private var tomorrowSlots: [BlackoutSlot]? = nil
    @State private var statusInfo: StatusAndCountdown = StatusAndCountdown(
        isBlackoutNow: false,
        isUnclear: false,
        countdownText: "--:--:--",
        nextSlotTime: "--:-- - --:--"
    )
    @State private var donations: [DonationItem] = DonationsRepository.DEFAULT_DONATIONS
    @State private var selectedPage: Int = 0
    @State private var isRefreshing: Bool = false
    @State private var isRouletteOpen: Bool = false
    @State private var now: Date = Date()

    public init() {}

    public var body: some View {
        let lang = AppStrings.resolveLanguage(settings.language)
        let currentMinuteOfDay = KyivZone.minuteOfDay(for: now)
        let palette = TimeOfDayPalette.getInterpolatedPalette(now: now)

        ZStack {
            // Minute-keyed ambient radial gradient background
            RadialGradient(
                gradient: Gradient(colors: [palette.primary, palette.secondary]),
                center: .center,
                startRadius: 20,
                endRadius: 480
            )
            .id("bg_\(currentMinuteOfDay)")
            .ignoresSafeArea()

            TabView(selection: $selectedPage) {
                MainScreen(
                    queue: settings.queue,
                    todaySlots: todaySlots,
                    tomorrowSlots: tomorrowSlots,
                    statusInfo: statusInfo,
                    notificationsEnabled: settings.notificationsEnabled,
                    isRefreshing: isRefreshing,
                    lang: lang,
                    now: now,
                    onToggleNotifications: {
                        settings = SettingsRepository.shared.updateNotificationsEnabled(!settings.notificationsEnabled)
                        NotificationScheduler.shared.syncAlarms()
                    },
                    onRefresh: {
                        Task { await refreshSchedules() }
                    }
                )
                .tag(0)

                SettingsScreen(
                    settings: settings,
                    lang: lang,
                    onUpdateSettings: { newSettings in
                        settings = newSettings
                        SettingsRepository.shared.saveSettings(newSettings)
                        reloadLocalSlots()
                        NotificationScheduler.shared.syncAlarms()
                    },
                    onSendTestAlert: {
                        NotificationScheduler.shared.showPreWarningNotification(
                            slotId: "test_manual",
                            settings: settings,
                            lang: lang,
                            intervalText: statusInfo.nextSlotTime,
                            isTest: true
                        )
                    },
                    onForceRefresh: {
                        Task { await refreshSchedules() }
                    },
                    onResetDefaults: {
                        AlertRegistry.shared.clearAll()
                        settings = SettingsRepository.shared.resetDefaults()
                        NotificationScheduler.shared.syncAlarms()
                    }
                )
                .tag(1)

                AboutScreen(
                    lang: lang,
                    donations: donations,
                    onOpenRoulette: {
                        isRouletteOpen = true
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if isRouletteOpen {
                ZhytomyrRouletteScreen(
                    lang: lang,
                    queue: settings.queue,
                    onClose: { isRouletteOpen = false }
                )
                .transition(.opacity)
                .zIndex(20)
            }

            // Bottom floating capsule navigation bar (hidden when Zhytomyr Roulette is open)
            if !isRouletteOpen {
                VStack {
                    Spacer()
                    HStack(spacing: 24) {
                        navButton(icon: "house.fill", index: 0)
                        navButton(icon: "gearshape.fill", index: 1)
                        navButton(icon: "info.circle.fill", index: 2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.85))
                    .clipShape(Capsule())
                    .padding(.bottom, 16)
                }
            }
        }
        .task {
            NotificationScheduler.shared.requestAuthorizationIfNeeded()
            reloadLocalSlots()
            await refreshSchedules()
            donations = await DonationsRepository.shared.getDonationsWithDailyRefresh(forceRefresh: true)
        }
        .task(id: scenePhase) {
            // Lifecycle-aware foreground ticker: runs ONLY while scenePhase == .active
            guard scenePhase == .active else { return }
            while !Task.isCancelled && scenePhase == .active {
                now = Date()
                statusInfo = ScheduleRepository.shared.calculateStatusAndCountdown(
                    slots: todaySlots,
                    tomorrowSlots: tomorrowSlots,
                    now: now
                )
                let sleepNs: UInt64 = (statusInfo.countdownText == "--:--:--") ? 15_000_000_000 : 1_000_000_000
                try? await Task.sleep(nanoseconds: sleepNs)
            }
        }
    }

    private func reloadLocalSlots() {
        todaySlots = ScheduleRepository.shared.getTodaySlots(queue: settings.queue, now: now)
        tomorrowSlots = ScheduleRepository.shared.getTomorrowSlots(queue: settings.queue, now: now)
        statusInfo = ScheduleRepository.shared.calculateStatusAndCountdown(
            slots: todaySlots,
            tomorrowSlots: tomorrowSlots,
            now: now
        )
    }

    private func refreshSchedules() async {
        isRefreshing = true
        _ = await ZtoeParser.fetchFullSchedule(urlStr: settings.url, now: Date())
        reloadLocalSlots()
        NotificationScheduler.shared.syncAlarms()
        isRefreshing = false
    }

    @ViewBuilder
    private func navButton(icon: String, index: Int) -> some View {
        Button(action: { selectedPage = index }) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(selectedPage == index ? .black : .white.opacity(0.75))
                .frame(width: 40, height: 40)
                .background(selectedPage == index ? Color.white : Color.clear)
                .clipShape(Circle())
        }
    }
}
