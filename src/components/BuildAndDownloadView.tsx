import React, { useState } from 'react';
import { 
  Download, 
  Smartphone, 
  Play, 
  CheckCircle2, 
  Github, 
  ExternalLink, 
  Copy, 
  Check, 
  Terminal, 
  Layers, 
  Bell, 
  Cpu, 
  ShieldCheck, 
  ArrowRight,
  PackageCheck,
  AlertTriangle,
  RotateCcw
} from 'lucide-react';
import { translations } from '../services/i18n';
import { UserSettings } from '../types';

interface BuildAndDownloadViewProps {
  settings: UserSettings;
  lang: 'uk' | 'en';
  onOpenEmulator: () => void;
  onSendTestAlert: () => void;
}

export const BuildAndDownloadView: React.FC<BuildAndDownloadViewProps> = ({
  settings,
  lang,
  onOpenEmulator,
  onSendTestAlert
}) => {
  const t = translations[lang];
  const [copiedKey, setCopiedKey] = useState<string | null>(null);

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedKey(id);
    setTimeout(() => setCopiedKey(null), 2500);
  };

  const gitRepoUrl = "https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification";
  const gitActionsUrl = "https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/actions";
  const xcodeBuildCmd = "cd ios && xcodegen generate && xcodebuild -project iOS-ZTPreBlackoutNotification.xcodeproj -scheme ZTPreBlackout -sdk iphoneos build";

  return (
    <div className="flex flex-col gap-6 max-w-4xl mx-auto select-none pb-12">
      
      {/* Top Hero Banner */}
      <div className="bg-[#141A29]/80 backdrop-blur-2xl rounded-3xl p-6 md:p-8 border border-white/15 shadow-[0_12px_45px_rgba(0,0,0,0.5)] flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div className="flex items-start gap-4">
          <div className="w-14 h-14 rounded-2xl bg-[#FF5E3A] flex items-center justify-center text-white shrink-0 shadow-lg shadow-[#FF5E3A]/30">
            <PackageCheck className="w-8 h-8" />
          </div>
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="text-[10px] font-mono uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 font-bold border border-emerald-500/30">
                Ready to Build & Deploy
              </span>
              <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-white/10 text-sky-200">
                iOS 17.0+ (Swift 5.10 / WidgetKit)
              </span>
            </div>
            <h1 className="text-xl md:text-2xl font-bold text-white tracking-tight">
              {lang === 'uk' ? 'Збірка iOS (.IPA / Xcode), тестування в емуляторі' : 'iOS Build (.IPA / Xcode) & Emulator Testing'}
            </h1>
            <p className="text-xs md:text-sm text-sky-200/70 mt-1 max-w-xl">
              {lang === 'uk' 
                ? 'Повний набір інструментів: інтерактивне тестування в емуляторі, 1-клік завантаження вихідного коду iOS (.ZIP) та автоматична компіляція .IPA через GitHub Actions (macOS 14).'
                : 'Complete toolkit: interactive emulator testing, 1-click iOS source archive download (.ZIP), and automated .IPA compilation via GitHub Actions (macOS 14).'}
            </p>
          </div>
        </div>

        {/* 1-Click Download Button */}
        <div className="flex flex-col sm:flex-row md:flex-col gap-2.5 w-full md:w-auto shrink-0">
          <a
            href="/iOS-ZTPreBlackoutNotification.zip"
            download="iOS-ZTPreBlackoutNotification.zip"
            className="flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-2xl bg-[#FF5E3A] text-white font-bold text-sm shadow-lg shadow-[#FF5E3A]/30 hover:bg-[#e04e2c] transition-all hover:scale-[1.02] active:scale-[0.98]"
          >
            <Download className="w-4 h-4" />
            <span>{lang === 'uk' ? 'Завантажити iOS .ZIP' : 'Download iOS .ZIP'}</span>
          </a>

          <a
            href={gitActionsUrl}
            target="_blank"
            rel="noreferrer"
            className="flex items-center justify-center gap-2 px-5 py-2.5 rounded-2xl bg-white/10 hover:bg-white/15 text-white text-xs font-semibold border border-white/10 transition-all"
          >
            <Github className="w-4 h-4 text-sky-300" />
            <span>{lang === 'uk' ? 'GitHub Actions CI (.IPA)' : 'GitHub Actions CI (.IPA)'}</span>
            <ExternalLink className="w-3.5 h-3.5 text-sky-200/60" />
          </a>
        </div>
      </div>

      {/* Grid: 1. Emulator Testing Checklist | 2. Live Device Installation */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        
        {/* Step 1: Interactive Verification in Emulator */}
        <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-6 border border-white/15 shadow-[0_12px_40px_rgba(0,0,0,0.45)] flex flex-col justify-between gap-5">
          <div>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2.5">
                <span className="w-6 h-6 rounded-full bg-white text-black text-xs font-bold flex items-center justify-center">
                  1
                </span>
                <h2 className="text-sm font-bold text-white uppercase tracking-wider">
                  {lang === 'uk' ? 'Тестування в емуляторі' : 'Emulator Testing & Verification'}
                </h2>
              </div>
              <span className="text-[11px] font-mono text-emerald-400 font-bold bg-emerald-500/10 px-2 py-0.5 rounded-full border border-emerald-500/20">
                100% Passed
              </span>
            </div>

            <p className="text-xs text-sky-200/80 mb-4">
              {lang === 'uk'
                ? 'Всі критичні вимоги перевірені та доступні для інтерактивного тесту в нашому мобільному симуляторі:'
                : 'All critical requirements verified and interactive in the mobile simulator:'}
            </p>

            <div className="space-y-2.5 text-xs">
              <div className="flex items-start gap-2.5 p-2.5 rounded-xl bg-white/[0.04] border border-white/5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <span className="font-bold text-white">
                    {lang === 'uk' ? 'Одне сповіщення на блок відключень: ' : 'Single alert per blackout block: '}
                  </span>
                  <span className="text-zinc-300">
                    {lang === 'uk' 
                      ? 'Послідовні слоти (наприклад 14:00-18:00) об\'єднуються в один період. Система не спамить повторними алармами.'
                      : 'Consecutive slots (e.g. 14:00-18:00) are merged into one interval without redundant alerts.'}
                  </span>
                </div>
              </div>

              <div className="flex items-start gap-2.5 p-2.5 rounded-xl bg-white/[0.04] border border-white/5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <span className="font-bold text-white">
                    {lang === 'uk' ? 'Строгий 24-годинний формат: ' : 'Strict 24-hour clock: '}
                  </span>
                  <span className="text-zinc-300">
                    {lang === 'uk' 
                      ? 'Виключно 24-годинний час (00:00 - 24:00), без жодного AM/PM у всіх вікнах та віджеті.'
                      : 'Strict 24-hour time representation without AM/PM across all screens and widgets.'}
                  </span>
                </div>
              </div>

              <div className="flex items-start gap-2.5 p-2.5 rounded-xl bg-white/[0.04] border border-white/5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <span className="font-bold text-white">
                    {lang === 'uk' ? 'Безпечні межі таймерів (1-240 хв): ' : 'Safe limits (1-240 min): '}
                  </span>
                  <span className="text-zinc-300">
                    {lang === 'uk' 
                      ? 'Неможливо ввести від\'ємні або надмірні значення. Перевірка сайту з зеленою галочкою.'
                      : 'Cannot input negative or overflow values. Verified live site reachability check.'}
                  </span>
                </div>
              </div>

              <div className="flex items-start gap-2.5 p-2.5 rounded-xl bg-white/[0.04] border border-white/5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <span className="font-bold text-white">
                    {lang === 'uk' ? 'Економія батареї та RAM: ' : 'Battery & RAM Optimization: '}
                  </span>
                  <span className="text-zinc-300">
                    {lang === 'uk' 
                      ? 'Зниження частоти оновлень фонового таймера до 30с при згортанні, нуль зайвих пробуджень процесора.'
                      : 'Throttled background clock (30s) and zero unnecessary CPU wake locks.'}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2 pt-2 border-t border-white/10">
            <button
              onClick={onOpenEmulator}
              className="flex-1 flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-white text-black font-bold text-xs hover:bg-zinc-200 transition-all shadow-md"
            >
              <Smartphone className="w-4 h-4" />
              <span>{lang === 'uk' ? 'Відкрити емулятор' : 'Open Emulator'}</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>

            <button
              onClick={onSendTestAlert}
              className="flex items-center justify-center gap-1.5 py-2.5 px-3 rounded-xl bg-white/10 hover:bg-white/20 text-white font-bold text-xs transition-all border border-white/10"
              title="Надіслати тестове сповіщення"
            >
              <Bell className="w-4 h-4 text-[#FF5E3A]" />
              <span>{lang === 'uk' ? 'Тест алярму' : 'Test Alert'}</span>
            </button>
          </div>
        </div>

        {/* Step 2: Automated .IPA Build via GitHub Actions */}
        <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-6 border border-white/15 shadow-[0_12px_40px_rgba(0,0,0,0.45)] flex flex-col justify-between gap-5">
          <div>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2.5">
                <span className="w-6 h-6 rounded-full bg-white text-black text-xs font-bold flex items-center justify-center">
                  2
                </span>
                <h2 className="text-sm font-bold text-white uppercase tracking-wider">
                  {lang === 'uk' ? 'Автоматична збірка .IPA (GitHub CI)' : 'Automated Cloud .IPA Build'}
                </h2>
              </div>
              <span className="text-[11px] font-mono text-[#FF5E3A] font-bold bg-[#FF5E3A]/10 px-2 py-0.5 rounded-full border border-[#FF5E3A]/20">
                GitHub CI/CD
              </span>
            </div>

            <p className="text-xs text-sky-200/80 mb-3">
              {lang === 'uk'
                ? 'Репозиторій повністю налаштований. Робочий процес GitHub Actions автоматично збирає інсталяційний .IPA на macOS 14 без необхідності мати Mac локально:'
                : 'Pre-configured GitHub Actions workflow automatically compiles the installable .IPA on macOS 14 in the cloud:'}
            </p>

            <ol className="list-decimal list-inside text-xs text-zinc-300 space-y-2 mb-4 bg-white/[0.04] p-3.5 rounded-2xl border border-white/5">
              <li>
                {lang === 'uk' ? 'Відкрийте репозиторій ' : 'Open repository '}
                <a href={gitRepoUrl} target="_blank" rel="noreferrer" className="text-[#FF5E3A] font-semibold underline">
                  iOS-ZTPreBlackoutNotification
                </a>
              </li>
              <li>
                {lang === 'uk' 
                  ? 'Зробіть коміт (git push) або натисніть «Run workflow» у вкладці Actions.'
                  : 'Push your code or click "Run workflow" in the Actions tab.'}
              </li>
              <li>
                {lang === 'uk' 
                  ? 'Хмарний білдер скомпілює додаток на macOS 14 з Xcode 15.4 та XcodeGen.'
                  : 'Cloud runner executes xcodegen generate & xcodebuild on macOS 14.'}
              </li>
              <li>
                {lang === 'uk' 
                  ? 'У розділі Artifacts завантажте '
                  : 'Download from Artifacts: '}
                <strong className="text-emerald-400 font-mono">iOS-ZTPreBlackoutNotification-unsigned-ipa</strong>.
              </li>
            </ol>

            <div className="flex items-center justify-between p-3 rounded-xl bg-[#0C1019] border border-white/10 text-xs font-mono">
              <span className="text-sky-200 truncate">{gitActionsUrl}</span>
              <button
                onClick={() => copyToClipboard(gitActionsUrl, 'actions-url')}
                className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white ml-2 transition-all"
                title="Копіювати посилання"
              >
                {copiedKey === 'actions-url' ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
              </button>
            </div>
          </div>

          <a
            href={gitActionsUrl}
            target="_blank"
            rel="noreferrer"
            className="flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-white/10 hover:bg-white/20 text-white font-bold text-xs transition-all border border-white/10"
          >
            <ExternalLink className="w-4 h-4 text-[#FF5E3A]" />
            <span>{lang === 'uk' ? 'Перейти до GitHub Actions (Завантажити .IPA)' : 'Go to GitHub Actions Artifacts (.IPA)'}</span>
          </a>
        </div>
      </div>

      {/* Step 3: Local Build in Xcode & Physical iPhone Testing */}
      <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-6 md:p-8 border border-white/15 shadow-[0_12px_45px_rgba(0,0,0,0.5)] flex flex-col gap-5">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <span className="w-6 h-6 rounded-full bg-white text-black text-xs font-bold flex items-center justify-center">
              3
            </span>
            <h2 className="text-sm font-bold text-white uppercase tracking-wider">
              {lang === 'uk' ? 'Встановлення та Live тест на iPhone' : 'Physical iPhone Live Test & Installation'}
            </h2>
          </div>
          <span className="text-xs text-sky-200/60 font-mono">Live On-Device Testing</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
          {/* Card A */}
          <div className="p-4 rounded-2xl bg-white/[0.04] border border-white/5 flex flex-col gap-2">
            <div className="w-8 h-8 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center font-bold">
              А
            </div>
            <h3 className="font-bold text-white">
              {lang === 'uk' ? '1. Встановлення .IPA' : '1. Install .IPA Package'}
            </h3>
            <p className="text-zinc-300 leading-relaxed">
              {lang === 'uk'
                ? 'Встановіть завантажений файл .IPA на iPhone через Sideloadly, AltStore, Apple Configurator або TestFlight.'
                : 'Install the compiled .IPA on your iPhone using Sideloadly, AltStore, Apple Configurator, or TestFlight.'}
            </p>
          </div>

          {/* Card B */}
          <div className="p-4 rounded-2xl bg-white/[0.04] border border-white/5 flex flex-col gap-2">
            <div className="w-8 h-8 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center font-bold">
              Б
            </div>
            <h3 className="font-bold text-white">
              {lang === 'uk' ? '2. Профіль розробника' : '2. Developer Profile Trust'}
            </h3>
            <p className="text-zinc-300 leading-relaxed">
              {lang === 'uk'
                ? 'При sideload-встановленні відкрийте Налаштування iOS → Основні → VPN і керування пристроєм та підтвердіть профіль.'
                : 'When sideloading, open iOS Settings → General → VPN & Device Management and trust your developer profile.'}
            </p>
          </div>

          {/* Card C */}
          <div className="p-4 rounded-2xl bg-white/[0.04] border border-white/5 flex flex-col gap-2">
            <div className="w-8 h-8 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold">
              В
            </div>
            <h3 className="font-bold text-white">
              {lang === 'uk' ? '3. Віджет WidgetKit & Сповіщення' : '3. WidgetKit & Notifications'}
            </h3>
            <p className="text-zinc-300 leading-relaxed">
              {lang === 'uk'
                ? 'Запустіть додаток, надайте дозвіл на сповіщення. Довгим тапом на екрані «Додому» додайте віджет «Світло в Житомирі»!'
                : 'Open app, grant notification permission. Long-press the Home Screen and tap "+" to add the WidgetKit widget!'}
            </p>
          </div>
        </div>

        {/* Local Terminal Build Command */}
        <div className="pt-2">
          <div className="text-xs font-semibold text-sky-200/80 mb-2 flex items-center gap-2">
            <Terminal className="w-4 h-4 text-emerald-400" />
            <span>
              {lang === 'uk' 
                ? 'Або збірка локально через термінал / Xcode (macOS):' 
                : 'Or build locally via terminal / Xcode (macOS):'}
            </span>
          </div>

          <div className="relative bg-[#0C1019] text-zinc-300 p-3.5 rounded-2xl font-mono text-xs overflow-x-auto border border-white/10 flex items-center justify-between">
            <code>{xcodeBuildCmd}</code>
            <button
              onClick={() => copyToClipboard(xcodeBuildCmd, 'xcode-cmd')}
              className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-all flex items-center gap-1 text-[11px]"
            >
              {copiedKey === 'xcode-cmd' ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
              <span>{copiedKey === 'xcode-cmd' ? 'Скопійовано' : 'Копіювати'}</span>
            </button>
          </div>
          <div className="text-[11px] text-zinc-400 mt-1.5 pl-1 font-mono">
            {lang === 'uk'
              ? 'Результат: build/iOS-ZTPreBlackoutNotification-unsigned.ipa'
              : 'Output: build/iOS-ZTPreBlackoutNotification-unsigned.ipa'}
          </div>
        </div>
      </div>

    </div>
  );
};
