const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const rootDir = process.cwd();

const filesToExpose = [
  {
    path: 'ios/project.yml',
    language: 'yaml',
    description: 'XcodeGen specification for ZTPreBlackout (iOS 17.0+), BlackoutWidgetExtension, and ZTPreBlackoutTests'
  },
  {
    path: 'ios/ZTPreBlackout/PrivacyInfo.xcprivacy',
    language: 'xml',
    description: 'Apple App Store Review Guideline 5.1.1 Privacy Manifest declaring UserDefaults (CA92.1) and zero tracking'
  },
  {
    path: 'ios/ZTPreBlackout/Info.plist',
    language: 'xml',
    description: 'iOS Info.plist with BGTaskScheduler identifiers, Photo Library usage descriptions, and encryption declaration'
  },
  {
    path: '.github/workflows/build-ipa.yml',
    language: 'yaml',
    description: 'GitHub Actions macOS 14 CI/CD workflow: runs npm test, generates Xcode project, and builds unsigned & signed .ipa'
  },
  {
    path: 'README.md',
    language: 'markdown',
    description: 'iOS 17.0+ Repository README (Swift 5.10, SwiftUI, WidgetKit, AppIntents, XcodeGen)'
  },
  {
    path: 'PRIVACY_POLICY.md',
    language: 'markdown',
    description: 'Official Privacy Policy compliant with Apple App Store Review Guidelines 5.1, PrivacyInfo.xcprivacy (CA92.1), and GDPR'
  },
  {
    path: 'ios/Shared/KyivZone.swift',
    language: 'swift',
    description: 'Europe/Kyiv to Europe/Kiev timezone fallback and Kyiv calendar utilities'
  },
  {
    path: 'ios/Shared/Models.swift',
    language: 'swift',
    description: 'Core data models, 12 sub-queues (1.1-6.2), default timers (15m / 30m), and Zhytomyr Roulette constants'
  },
  {
    path: 'ios/Shared/AppStrings.swift',
    language: 'swift',
    description: 'Bilingual Ukrainian/English strings with 100% parity with i18n.ts'
  },
  {
    path: 'ios/Shared/ZtoeParser.swift',
    language: 'swift',
    description: 'ZTOE Windows-1251 HTML scraper, leaf table matcher, explicit red hex detector, and 48 half-hour slot extractor'
  },
  {
    path: 'ios/Shared/ScheduleRepository.swift',
    language: 'swift',
    description: 'Shared App Group UserDefaults storage, contiguous block merging (Rule 1), and cross-midnight / tomorrow countdown engine'
  },
  {
    path: 'ios/Shared/SettingsRepository.swift',
    language: 'swift',
    description: 'Type-safe UserDefaults reader/writer and master notification toggle sound/haptic state preservation'
  },
  {
    path: 'ios/Shared/DonationsRepository.swift',
    language: 'swift',
    description: 'Startup + 24h charity donations.json sync with ETag conditional caching and Ukrainian two-part TLD favicon loader'
  },
  {
    path: 'ios/Shared/TimeOfDayPalette.swift',
    language: 'swift',
    description: 'Smooth 4-anchor Kyiv-time ambient color interpolation (Morning, Day, Evening, Night)'
  },
  {
    path: 'ios/ZTPreBlackout/Notifications/AlertRegistry.swift',
    language: 'swift',
    description: 'Single-notification deduplication per contiguous block and backward clock-change reset'
  },
  {
    path: 'ios/ZTPreBlackout/Notifications/NotificationScheduler.swift',
    language: 'swift',
    description: 'UNUserNotificationCenter exact Europe/Kyiv calendar triggers, cross-queue sweep, and in-flight protection'
  },
  {
    path: 'ios/ZTPreBlackout/Worker/BackgroundSyncManager.swift',
    language: 'swift',
    description: 'BGAppRefreshTask periodic background sync and NSSystemClockDidChange observer'
  },
  {
    path: 'ios/ZTPreBlackout/UI/TimelineBar.swift',
    language: 'swift',
    description: 'SwiftUI САЗУ-ИТ 24h 48-slot analog electricity meter faceplate and Unclear grey state'
  },
  {
    path: 'ios/ZTPreBlackout/UI/MainScreen.swift',
    language: 'swift',
    description: 'SwiftUI Main Schedule Screen with Hero countdown card, Today/Tomorrow tabs, 24h TimelineBar, and Facebook/ZTOE links'
  },
  {
    path: 'ios/ZTPreBlackout/UI/SettingsScreen.swift',
    language: 'swift',
    description: 'SwiftUI Settings Screen with 1.1-6.2 queue picker, 4-step help sheet, URL verifier, and timer steppers'
  },
  {
    path: 'ios/ZTPreBlackout/UI/AboutScreen.swift',
    language: 'swift',
    description: 'SwiftUI About Screen with Charity donations list, Zhytomyr Roulette launch button, and ordered GitHub links'
  },
  {
    path: 'ios/ZTPreBlackout/UI/ZhytomyrRouletteScreen.swift',
    language: 'swift',
    description: 'SwiftUI Zhytomyr Roulette mini-game with 9 foil textures, MP3 audio tracks, Power Shop, Milestone Progress Bar, and Share Card'
  },
  {
    path: 'ios/ZTPreBlackout/UI/BlackoutAppNavigation.swift',
    language: 'swift',
    description: 'Horizontal page TabView navigation and scenePhase-aware 1s/15s foreground ticker'
  },
  {
    path: 'ios/ZTPreBlackout/ZTPreBlackoutApp.swift',
    language: 'swift',
    description: 'Main iOS SwiftUI App entry point'
  },
  {
    path: 'ios/BlackoutWidgetExtension/WidgetIntents.swift',
    language: 'swift',
    description: 'iOS 17+ interactive AppIntents (RefreshScheduleIntent and ToggleAlertsIntent) for Home Screen widgets'
  },
  {
    path: 'ios/BlackoutWidgetExtension/BlackoutWidget.swift',
    language: 'swift',
    description: 'WidgetKit systemSmall (2x1) & systemMedium (3x2) widgets with 20% transparency, HHг. MMхв. countdown, and САЗУ-ИТ bitmap'
  },
  {
    path: 'ios/ZTPreBlackoutTests/ZtoeParserTests.swift',
    language: 'swift',
    description: 'XCTest automated unit test suite verifying ZtoeParser, ScheduleRepository, and critical invariants'
  }
];

const entries = filesToExpose.map((item) => {
  const fullPath = path.join(rootDir, item.path);
  const content = fs.readFileSync(fullPath, 'utf-8');
  return {
    path: item.path,
    language: item.language,
    description: item.description,
    content
  };
});

const tsOutput = `// Auto-generated from /ios native Swift project files
export interface IosProjectFile {
  path: string;
  language: string;
  description: string;
  content: string;
}

export const IOS_PROJECT_FILES: IosProjectFile[] = ${JSON.stringify(entries, null, 2)};
`;

fs.writeFileSync(path.join(rootDir, 'src/data/iosProjectFiles.ts'), tsOutput, 'utf-8');
console.log('Generated src/data/iosProjectFiles.ts with', entries.length, 'files.');

execSync('python3 -m zipfile -c public/iOS-ZTPreBlackoutNotification.zip ios .github/workflows/build-ipa.yml README.md PRIVACY_POLICY.md donations.json IOS_HANDOVER.md', {
  cwd: rootDir,
  stdio: 'inherit'
});
console.log('Created public/iOS-ZTPreBlackoutNotification.zip');
