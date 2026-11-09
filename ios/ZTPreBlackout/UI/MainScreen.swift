import SwiftUI

public struct MainScreen: View {
    public let queue: String
    public let todaySlots: [BlackoutSlot]
    public let tomorrowSlots: [BlackoutSlot]?
    public let statusInfo: StatusAndCountdown
    public let notificationsEnabled: Bool
    public let isRefreshing: Bool
    public let lang: String
    public let now: Date
    public let onToggleNotifications: () -> Void
    public let onRefresh: () -> Void

    @State private var selectedDayTab: Int = 0
    @State private var pulseActive: Bool = false

    public init(
        queue: String,
        todaySlots: [BlackoutSlot],
        tomorrowSlots: [BlackoutSlot]?,
        statusInfo: StatusAndCountdown,
        notificationsEnabled: Bool,
        isRefreshing: Bool,
        lang: String,
        now: Date,
        onToggleNotifications: @escaping () -> Void,
        onRefresh: @escaping () -> Void
    ) {
        self.queue = queue
        self.todaySlots = todaySlots
        self.tomorrowSlots = tomorrowSlots
        self.statusInfo = statusInfo
        self.notificationsEnabled = notificationsEnabled
        self.isRefreshing = isRefreshing
        self.lang = lang
        self.now = now
        self.onToggleNotifications = onToggleNotifications
        self.onRefresh = onRefresh
    }

    public var body: some View {
        let isTomorrowSelected = selectedDayTab == 1
        let activeSlots: [BlackoutSlot] = isTomorrowSelected ? (tomorrowSlots ?? []) : todaySlots
        let activeSlotsSignature = activeSlots.map { $0.status == .POWER_OFF ? "1" : "0" }.joined()
        let activeIntervals = ScheduleRepository.shared.getDetailedIntervals(slots: activeSlots)
        let isUnclear = statusInfo.isUnclear || todaySlots.isEmpty

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                // Top Header: Queue + Master Notification Switch
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(AppStrings.APP_NAME)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text(lang == "en" ? "Queue \(queue)" : "Черга \(queue)")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { notificationsEnabled },
                        set: { _ in onToggleNotifications() }
                    ))
                    .labelsHidden()
                    .tint(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                }
                .padding(.horizontal, 4)

                // Hero Status & Countdown Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isUnclear
                                  ? Color(red: 0x9C / 255.0, green: 0xA3 / 255.0, blue: 0xAF / 255.0)
                                  : (statusInfo.isBlackoutNow
                                     ? Color(red: 0xEF / 255.0, green: 0x44 / 255.0, blue: 0x44 / 255.0)
                                     : Color(red: 0x10 / 255.0, green: 0xB9 / 255.0, blue: 0x81 / 255.0)))
                            .frame(width: 10, height: 10)
                            .scaleEffect(statusInfo.isBlackoutNow && pulseActive ? 1.25 : 1.0)

                        Text(isUnclear
                             ? AppStrings.statusUnclear(lang)
                             : (statusInfo.isBlackoutNow
                                ? AppStrings.widgetPowerOff(lang)
                                : AppStrings.widgetPowerOn(lang)))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(statusInfo.countdownText)
                        .font(.system(size: 36, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)

                    HStack {
                        Text(lang == "en" ? "Next period:" : "Найближчий період:")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text(isUnclear ? "--:-- - --:--" : statusInfo.nextSlotTime)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 24h Schedule Card + Outage Hours List keyed by (queue, selectedDayTab, activeSlotsSignature)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button(lang == "en" ? "Today" : "Сьогодні") {
                            selectedDayTab = 0
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(selectedDayTab == 0 ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedDayTab == 0 ? Color.white : Color.white.opacity(0.08))
                        .cornerRadius(12)

                        Button(lang == "en" ? "Tomorrow" : "Завтра") {
                            selectedDayTab = 1
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(selectedDayTab == 1 ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedDayTab == 1 ? Color.white : Color.white.opacity(0.08))
                        .cornerRadius(12)

                        Spacer()

                        Button(action: onRefresh) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    TimelineBar(
                        slots: activeSlots,
                        isUnclear: isUnclear,
                        currentMinuteOfDay: KyivZone.minuteOfDay(for: now),
                        showCurrentTimeNeedle: !isTomorrowSelected,
                        lang: lang
                    )
                    .id("\(queue)_\(selectedDayTab)_\(activeSlotsSignature)")

                    if !isUnclear {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppStrings.blackoutHoursForDayHeader(lang))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.75))

                            ForEach(activeIntervals) { interval in
                                HStack {
                                    Text("\(interval.startStr) – \(interval.endStr)")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(String(format: "%.1f год", interval.durationHours))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(12)
                            }
                        }
                        .id("intervals_\(queue)_\(selectedDayTab)_\(activeSlotsSignature)")
                    }
                }
                .padding(16)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // Emergency Outages Facebook Link & ZTOE Website Schedules Link
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppStrings.emergencyOutagesLabel(lang))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))

                    if let fbUrl = URL(string: AppStrings.EMERGENCY_OUTAGES_URL) {
                        Link(destination: fbUrl) {
                            HStack(spacing: 8) {
                                Image(systemName: "link.circle.fill")
                                    .foregroundColor(Color(red: 0x18 / 255.0, green: 0x77 / 255.0, blue: 0xF2 / 255.0))
                                Text(AppStrings.EMERGENCY_OUTAGES_URL)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                        }
                    }

                    if let ztoeUrl = URL(string: AppStrings.DEFAULT_ZTOE_URL) {
                        Link(destination: ztoeUrl) {
                            HStack(spacing: 8) {
                                Image(systemName: "globe")
                                    .foregroundColor(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                                Text(AppStrings.ztoeSiteSchedulesLinkLabel(lang))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
    }
}
