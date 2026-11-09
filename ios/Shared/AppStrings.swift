import Foundation

public enum AppStrings {
    public static let APP_NAME = "Світло в Житомирі"
    public static let DEFAULT_ZTOE_URL = "https://www.ztoe.com.ua/unhooking-search.php"
    public static let EMERGENCY_OUTAGES_URL = "https://www.facebook.com/ztoe.com.ua"
    public static let ABOUT_GITHUB_README_URL = "https://github.com/IgorZaharov/Android-ZTBlackoutPreWarning/blob/main/README.md"
    public static let ABOUT_IOS_GITHUB_URL = "https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification"
    public static let ABOUT_ISSUES_URL = "https://github.com/IgorZaharov/Android-ZTBlackoutPreWarning/issues"

    public static func resolveLanguage(_ rawLang: String) -> String {
        if rawLang == "uk" || rawLang == "en" {
            return rawLang
        }
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "uk"
        return preferred.hasPrefix("en") ? "en" : "uk"
    }

    public static func widgetPowerOn(_ lang: String) -> String {
        lang == "en" ? "POWER ON" : "СВІТЛО Є"
    }

    public static func widgetPowerOff(_ lang: String) -> String {
        lang == "en" ? "POWER OFF" : "СВІТЛА НЕМАЄ"
    }

    public static func schedulesUnclear(_ lang: String) -> String {
        lang == "en" ? "Outages unclear" : "Графіки не діють"
    }

    public static func statusUnclear(_ lang: String) -> String {
        lang == "en" ? "Unclear" : "Невідомо"
    }

    public static func blackoutHoursForDayHeader(_ lang: String) -> String {
        lang == "en" ? "BLACKOUT HOURS FOR TODAY:" : "ГОДИНИ БЕЗ СВІТЛА НА ЦЕЙ ДЕНЬ:"
    }

    public static func emergencyOutagesLabel(_ lang: String) -> String {
        lang == "en" ? "Emergency outages info:" : "Інформація про аварійні відключення:"
    }

    public static func ztoeSiteSchedulesLinkLabel(_ lang: String) -> String {
        lang == "en" ? "Blackout schedules on website" : "Графіки відключень на сайті"
    }

    public static func donationsSectionTitle(_ lang: String) -> String {
        "Charity / Благодійність і Пожертви"
    }

    public static func aboutGithubRepoLabel(_ lang: String) -> String {
        "Світло в Житомирі на Github"
    }

    public static func queueHelpTitle(_ lang: String) -> String {
        lang == "en" ? "How to find your queue?" : "Як дізнатися свою чергу?"
    }

    public static func queueHelpConfirm(_ lang: String) -> String {
        lang == "en" ? "Got it" : "Зрозуміло"
    }

    public static func queueHelpSteps(_ lang: String) -> [String] {
        if lang == "en" {
            return [
                "1. Open the website https://www.ztoe.com.ua/unhooking-search.php",
                "2. Select your REM (district), settlement, street, and building number.",
                "3. Click the search button to load the outage table for your address.",
                "4. Note the sub-queue number (for example, 1.1, 2.2, or 4.1) and select it in the app."
            ]
        }
        return [
            "1. Перейдіть на сайт https://www.ztoe.com.ua/unhooking-search.php",
            "2. Оберіть ваш РЕМ, населений пункт, вулицю та номер будинку.",
            "3. Натисніть кнопку пошуку, щоб побачити таблицю відключень за вашою адресою.",
            "4. Подивіться номер підчерги (наприклад, 1.1, 2.2 або 4.1) та оберіть його у додатку."
        ]
    }

    public static func siteAddressTitle(_ lang: String) -> String {
        lang == "en" ? "Schedule Website URL" : "Адреса сайту графіків"
    }

    public static func siteReachable(_ lang: String) -> String {
        lang == "en" ? "Website verified & reachable" : "Сайт доступний і перевірений"
    }

    public static func errorNoQueuesFound(_ lang: String) -> String {
        lang == "en" ? "No blackout queues found on page" : "Черги відключень не знайдено"
    }

    public static func languageTitle(_ lang: String) -> String {
        lang == "en" ? "Application Language" : "Мова додатку"
    }

    public static func testAlertBtn(_ lang: String) -> String {
        lang == "en" ? "Send Test Notification" : "Тестове сповіщення"
    }

    public static func refreshBtn(_ lang: String) -> String {
        lang == "en" ? "Refresh Schedule Now" : "Оновити графік зараз"
    }

    public static func resetDefaultsBtn(_ lang: String) -> String {
        lang == "en" ? "Reset to Defaults" : "Скинути налаштування"
    }

    public static func rouletteLaunchButton(_ lang: String) -> String {
        lang == "en" ? "Zhytomyr Roulette" : "Житомирська Рулетка"
    }

    public static func rouletteAllTimeBestScoreLabel(_ lang: String) -> String {
        lang == "en" ? "All time best score" : "Найкращий Результат"
    }

    public static func roulettePowerPointsLabel(_ lang: String) -> String {
        lang == "en" ? "Power Points" : "Бали Потужності"
    }

    public static func roulettePowerShopBtn(_ lang: String) -> String {
        lang == "en" ? "Power Shop" : "Магазин Потужності"
    }

    public static func rouletteMainMenuBtn(_ lang: String) -> String {
        lang == "en" ? "Main Menu" : "Головне Меню"
    }

    public static func rouletteShareBtn(_ lang: String) -> String {
        lang == "en" ? "Share" : "Поділитися"
    }

    public static func rouletteDownloadImageBtn(_ lang: String) -> String {
        lang == "en" ? "Download Image" : "Завантажити зображення"
    }

    public static func rouletteSoundLabel(_ lang: String) -> String {
        lang == "en" ? "Sound" : "Звук"
    }

    public static func rouletteMusicLabel(_ lang: String) -> String {
        lang == "en" ? "Music" : "Музика"
    }

    public static func notificationTitle(_ lang: String, isTest: Bool = false) -> String {
        if lang == "en" {
            return isTest ? "Test Alert: Power Outage" : "Warning: Power Outage"
        }
        return isTest ? "Тест: відключення світла" : "Попередження: відключення світла"
    }

    public static func notificationBody(
        _ lang: String,
        queue: String,
        advanceMinutes: Int,
        intervalText: String
    ) -> String {
        if lang == "en" {
            return "Queue \(queue): Power off in \(advanceMinutes) min (\(intervalText))."
        }
        return "Черга \(queue): відключення через \(advanceMinutes) хв (\(intervalText))."
    }
}
