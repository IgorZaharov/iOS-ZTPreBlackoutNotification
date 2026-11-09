import SwiftUI

public struct SettingsScreen: View {
    public let settings: UserSettings
    public let lang: String
    public let onUpdateSettings: (UserSettings) -> Void
    public let onSendTestAlert: () -> Void
    public let onForceRefresh: () -> Void
    public let onResetDefaults: () -> Void

    @State private var showQueueHelp: Bool = false
    @State private var urlDraft: String = ""
    @State private var advanceDraft: String = ""
    @State private var refreshDraft: String = ""
    @State private var isUrlVerified: Bool = true

    public init(
        settings: UserSettings,
        lang: String,
        onUpdateSettings: @escaping (UserSettings) -> Void,
        onSendTestAlert: @escaping () -> Void,
        onForceRefresh: @escaping () -> Void,
        onResetDefaults: @escaping () -> Void
    ) {
        self.settings = settings
        self.lang = lang
        self.onUpdateSettings = onUpdateSettings
        self.onSendTestAlert = onSendTestAlert
        self.onForceRefresh = onForceRefresh
        self.onResetDefaults = onResetDefaults
        _urlDraft = State(initialValue: settings.url)
        _advanceDraft = State(initialValue: "\(settings.advanceNoticeMinutes)")
        _refreshDraft = State(initialValue: "\(settings.refreshIntervalMinutes)")
        _isUrlVerified = State(initialValue: ZtoeParser.isValidScheduleUrl(settings.url))
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                // 1. Queue Selector & 4-Step Help Modal Button
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                        Text(lang == "en" ? "Select Your Queue" : "Оберіть вашу чергу")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { showQueueHelp = true }) {
                            Text("?")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                                .clipShape(Circle())
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(UserSettings.ALL_QUEUES, id: \.self) { q in
                            Button(action: {
                                var updated = settings
                                updated.queue = q
                                onUpdateSettings(updated)
                            }) {
                                Text(q)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(settings.queue == q
                                                ? Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0)
                                                : Color.white.opacity(0.08))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 2. Site URL Card
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppStrings.siteAddressTitle(lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)

                    TextField("https://www.ztoe.com.ua/unhooking-search.php", text: $urlDraft)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.35))
                        .cornerRadius(12)
                        .onChange(of: urlDraft) { _, newValue in
                            let valid = ZtoeParser.isValidScheduleUrl(newValue)
                            isUrlVerified = valid
                            if valid {
                                var updated = settings
                                updated.url = newValue
                                onUpdateSettings(updated)
                            }
                        }

                    Text(isUrlVerified ? AppStrings.siteReachable(lang) : AppStrings.errorNoQueuesFound(lang))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isUrlVerified ? .green : .red)
                }
                .padding(16)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 3. Timers & Notification Switches
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(lang == "en" ? "Advance Warning (1-240 min)" : "Попередження за (1-240 хв)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Stepper("\(settings.advanceNoticeMinutes) min", value: Binding(
                            get: { settings.advanceNoticeMinutes },
                            set: { val in
                                var updated = settings
                                updated.advanceNoticeMinutes = min(240, max(1, val))
                                onUpdateSettings(updated)
                            }
                        ), in: 1...240)
                        .labelsHidden()
                    }

                    HStack {
                        Text(lang == "en" ? "Refresh Interval (1-240 min)" : "Інтервал оновлення (1-240 хв)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Stepper("\(settings.refreshIntervalMinutes) min", value: Binding(
                            get: { settings.refreshIntervalMinutes },
                            set: { val in
                                var updated = settings
                                updated.refreshIntervalMinutes = min(240, max(1, val))
                                onUpdateSettings(updated)
                            }
                        ), in: 1...240)
                        .labelsHidden()
                    }

                    Toggle(lang == "en" ? "Enable Notifications" : "Увімкнути сповіщення", isOn: Binding(
                        get: { settings.notificationsEnabled },
                        set: { enabled in
                            let updated = SettingsRepository.shared.updateNotificationsEnabled(enabled)
                            onUpdateSettings(updated)
                        }
                    ))
                    .tint(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                    .foregroundColor(.white)

                    Toggle(lang == "en" ? "Notification Sound" : "Звук сповіщення", isOn: Binding(
                        get: { settings.soundEnabled },
                        set: { val in
                            var updated = settings
                            updated.soundEnabled = val
                            onUpdateSettings(updated)
                        }
                    ))
                    .tint(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                    .foregroundColor(.white)

                    Toggle(lang == "en" ? "Vibration / Haptics" : "Вібрація", isOn: Binding(
                        get: { settings.vibrationEnabled },
                        set: { val in
                            var updated = settings
                            updated.vibrationEnabled = val
                            onUpdateSettings(updated)
                        }
                    ))
                    .tint(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                    .foregroundColor(.white)
                }
                .padding(16)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 4. Language Selector ("Системна", "Українська", "English")
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppStrings.languageTitle(lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        ForEach([
                            ("system", "Системна"),
                            ("uk", "Українська"),
                            ("en", "English")
                        ], id: \.0) { code, label in
                            Button(action: {
                                var updated = settings
                                updated.language = code
                                onUpdateSettings(updated)
                            }) {
                                Text(label)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(settings.language == code
                                                ? Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0)
                                                : Color.white.opacity(0.08))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 5. Action Buttons: Test Alert, Refresh, Reset Defaults
                VStack(spacing: 10) {
                    Button(action: onSendTestAlert) {
                        Text(AppStrings.testAlertBtn(lang))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                            .cornerRadius(14)
                    }

                    Button(action: onForceRefresh) {
                        Text(AppStrings.refreshBtn(lang))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(14)
                    }

                    Button(action: onResetDefaults) {
                        Text(AppStrings.resetDefaultsBtn(lang))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.15))
                            .cornerRadius(14)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
        .sheet(isPresented: $showQueueHelp) {
            VStack(alignment: .leading, spacing: 14) {
                Text(AppStrings.queueHelpTitle(lang))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                ForEach(AppStrings.queueHelpSteps(lang), id: \.self) { step in
                    Text(step)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                }

                Button(action: { showQueueHelp = false }) {
                    Text(AppStrings.queueHelpConfirm(lang))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                        .cornerRadius(14)
                }
            }
            .padding(24)
            .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0))
            .presentationDetents([.medium])
        }
    }
}
