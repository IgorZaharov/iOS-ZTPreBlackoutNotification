import React, { useState, useEffect } from 'react';
import { 
  Github, 
  ExternalLink, 
  Bug, 
  Monitor, 
  ShieldAlert, 
  Zap,
  Globe,
  FileText,
  X
} from 'lucide-react';
import { translations } from '../services/i18n';
import {
  DonationLink,
  getCachedDonations,
  getDonationsWithDailyRefresh,
  getFaviconCandidateUrls,
} from '../services/donationsService';
import { ZhytomyrRouletteModal } from './ZhytomyrRouletteModal';
import privacyPolicyMarkdown from '../../PRIVACY_POLICY.md?raw';

declare const __APP_VERSION__: string | undefined;
const CURRENT_BUILD_VERSION = `v${typeof __APP_VERSION__ !== 'undefined' && /^[0-9]+\.[0-9]+/.test(__APP_VERSION__) ? __APP_VERSION__ : '1.3.5'}`;

const DonationFavicon: React.FC<{ url: string; title: string }> = ({ url, title }) => {
  const candidates = getFaviconCandidateUrls(url);
  const [candidateIdx, setCandidateIdx] = useState(0);

  if (candidateIdx >= candidates.length) {
    return <Globe className="w-5 h-5 text-white" />;
  }

  return (
    <img
      src={candidates[candidateIdx]}
      alt={title}
      className="w-5 h-5 rounded-[4px] object-contain"
      onError={() => setCandidateIdx((prev) => prev + 1)}
    />
  );
};

interface AboutViewProps {
  lang: 'uk' | 'en';
  onOpenRoulette?: () => void;
}

export const AboutView: React.FC<AboutViewProps> = ({ lang, onOpenRoulette }) => {
  const t = translations[lang];
  const [donations, setDonations] = useState<DonationLink[]>(() => getCachedDonations());
  const [isRouletteOpen, setIsRouletteOpen] = useState(false);
  const [isPrivacyPolicyOpen, setIsPrivacyPolicyOpen] = useState(false);

  useEffect(() => {
    let mounted = true;
    getDonationsWithDailyRefresh(Date.now(), true).then((items) => {
      if (mounted) {
        setDonations(items);
      }
    });
    return () => {
      mounted = false;
    };
  }, []);

  return (
    <div className="flex flex-col gap-4 max-w-lg mx-auto select-none">
      {/* App Identity Banner */}
      <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-6 border border-white/15 shadow-[0_16px_44px_rgba(0,0,0,0.55)] flex flex-col items-center text-center">
        <div className="w-16 h-16 rounded-2xl bg-[#FF5E3A] flex items-center justify-center text-white shadow-lg mb-3 shadow-[#FF5E3A]/30">
          <Zap className="w-8 h-8 fill-current" />
        </div>

        <h1 className="text-xl font-bold text-white tracking-tight">
          {t.appTitle}
        </h1>
        <p className="text-xs text-sky-200/70 mt-1 max-w-xs">
          {t.appSubtitle}
        </p>

        <div className="flex items-center gap-2 mt-3 text-[11px] font-mono">
          <span className="px-3 py-1 rounded-full bg-white/10 text-sky-100 font-semibold border border-white/15">
            {CURRENT_BUILD_VERSION}
          </span>
        </div>
      </div>

      {/* Description Card */}
      <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-5 border border-white/15 shadow-[0_16px_44px_rgba(0,0,0,0.55)] flex flex-col gap-3">
        <h2 className="text-xs font-bold uppercase tracking-wider text-sky-200/70">
          {lang === 'uk' ? 'Опис застосунку' : 'App Description'}
        </h2>
        <p className="text-xs leading-relaxed text-zinc-200">
          {t.aboutDesc}
        </p>
        <p className="text-xs leading-relaxed text-sky-200/80 bg-white/[0.06] p-3 rounded-2xl border border-white/10">
          {t.aboutDesktopNotice}
        </p>
      </div>

      {/* Developer & GitHub Links */}
      <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-5 border border-white/15 shadow-[0_16px_44px_rgba(0,0,0,0.55)] flex flex-col gap-3">
        <h2 className="text-xs font-bold uppercase tracking-wider text-sky-200/70">
          {t.aboutLinks}
        </h2>

        {/* 1. Main GitHub Profile */}
        <a
          href="https://github.com/IgorZaharov"
          target="_blank"
          rel="noopener noreferrer"
          title="https://github.com/IgorZaharov"
          className="flex items-center justify-between p-3.5 rounded-2xl bg-white/[0.06] hover:bg-white/[0.12] border border-white/10 transition-all group overflow-hidden"
        >
          <div className="flex items-center gap-3.5 min-w-0 flex-1 mr-2">
            <div className="w-10 h-10 rounded-2xl bg-white text-black flex items-center justify-center shrink-0 shadow-sm">
              <Github className="w-5 h-5" />
            </div>
            <div className="min-w-0 flex-1">
              <div className="text-xs font-bold text-white group-hover:text-[#FF5E3A] transition-colors truncate">
                {t.aboutGithubProfile}
              </div>
              <div className="text-[11px] text-sky-200/70 font-mono truncate">
                github.com/IgorZaharov
              </div>
            </div>
          </div>
          <ExternalLink className="w-4 h-4 text-sky-200/70 group-hover:text-white transition-colors shrink-0" />
        </a>

        {/* 2. Світло в Житомирі на Github */}
        <a
          href="https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/blob/main/README.md"
          target="_blank"
          rel="noopener noreferrer"
          title="https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/blob/main/README.md"
          className="flex items-center justify-between p-3.5 rounded-2xl bg-white/[0.06] hover:bg-white/[0.12] border border-white/10 transition-all group overflow-hidden"
        >
          <div className="flex items-center gap-3.5 min-w-0 flex-1 mr-2">
            <div className="w-10 h-10 rounded-2xl bg-white/10 text-white flex items-center justify-center shrink-0 border border-white/20">
              <Monitor className="w-5 h-5" />
            </div>
            <div className="min-w-0 flex-1">
              <div className="text-xs font-bold text-white group-hover:text-[#FF5E3A] transition-colors truncate">
                {t.aboutDesktopRepo}
              </div>
              <div className="text-[11px] text-sky-200/70 font-mono truncate">
                github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/blob/main/README.md
              </div>
            </div>
          </div>
          <ExternalLink className="w-4 h-4 text-sky-200/70 group-hover:text-white transition-colors shrink-0" />
        </a>

        {/* 3. Project Issues & Requests */}
        <a
          href="https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/issues"
          target="_blank"
          rel="noopener noreferrer"
          title="https://github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/issues"
          className="flex items-center justify-between p-3.5 rounded-2xl bg-white/[0.06] hover:bg-white/[0.12] border border-white/10 transition-all group overflow-hidden"
        >
          <div className="flex items-center gap-3.5 min-w-0 flex-1 mr-2">
            <div className="w-10 h-10 rounded-2xl bg-[#FF5E3A] text-white flex items-center justify-center shrink-0 shadow-sm shadow-[#FF5E3A]/30">
              <Bug className="w-5 h-5" />
            </div>
            <div className="min-w-0 flex-1">
              <div className="text-xs font-bold text-white group-hover:text-[#FF5E3A] transition-colors truncate">
                {t.aboutRepoIssues}
              </div>
              <div className="text-[11px] text-sky-200/70 font-mono truncate">
                github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/issues
              </div>
            </div>
          </div>
          <ExternalLink className="w-4 h-4 text-sky-200/70 group-hover:text-white transition-colors shrink-0" />
        </a>
      </div>

      {/* Donations / Благодійність і Пожертви */}
      <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-5 border border-white/15 shadow-[0_16px_44px_rgba(0,0,0,0.55)] flex flex-col gap-3">
        <h2 className="text-xs font-bold uppercase tracking-wider text-sky-200/70">
          {t.aboutDonations}
        </h2>

        {donations.map((item, idx) => (
          <a
            key={`${item.url}_${idx}`}
            href={item.url}
            target="_blank"
            rel="noopener noreferrer"
            title={item.url}
            className="flex items-center justify-between p-3.5 rounded-2xl bg-white/[0.06] hover:bg-white/[0.12] border border-white/10 transition-all group overflow-hidden"
          >
            <div className="flex items-center gap-3.5 min-w-0 flex-1 mr-2">
              <div className="w-10 h-10 rounded-2xl bg-white/15 border border-white/15 flex items-center justify-center shrink-0 shadow-sm">
                <DonationFavicon url={item.url} title={item.title} />
              </div>
              <div className="min-w-0 flex-1">
                <div className="text-xs font-bold text-white group-hover:text-[#FF5E3A] transition-colors truncate">
                  {item.title}
                </div>
                <div className="text-[11px] text-sky-200/70 font-mono truncate">
                  {item.url.replace(/^https?:\/\//, '')}
                </div>
              </div>
            </div>
            <ExternalLink className="w-4 h-4 text-sky-200/70 group-hover:text-white transition-colors shrink-0" />
          </a>
        ))}
      </div>

      {/* Житомирська Рулетка / Zhytomyr Roulette Button (after Donations block) */}
      <button
        type="button"
        data-testid="open-zhytomyr-roulette-btn"
        onClick={() => {
          if (onOpenRoulette) {
            onOpenRoulette();
          } else {
            setIsRouletteOpen(true);
          }
        }}
        className="w-full bg-[#141A29]/75 hover:bg-[#1B2338]/85 backdrop-blur-2xl rounded-3xl p-4 border border-amber-300/35 shadow-[0_16px_44px_rgba(0,0,0,0.55)] flex items-center justify-center text-sm font-bold text-amber-200 transition-all cursor-pointer active:scale-[0.99]"
      >
        {lang === 'en' ? 'Zhytomyr Roulette' : 'Житомирська Рулетка'}
      </button>

      {!onOpenRoulette && (
        <ZhytomyrRouletteModal
          isOpen={isRouletteOpen}
          onClose={() => setIsRouletteOpen(false)}
          lang={lang}
        />
      )}

      {/* Disclaimer */}
      <div className="bg-[#141A29]/75 backdrop-blur-2xl rounded-3xl p-5 border border-white/15 shadow-[0_16px_44px_rgba(0,0,0,0.55)] flex items-center gap-3.5">
        <div className="w-10 h-10 rounded-2xl bg-amber-500/15 text-amber-300 flex items-center justify-center shrink-0 border border-amber-500/25">
          <ShieldAlert className="w-5 h-5" />
        </div>
        <div className="min-w-0 flex-1 text-[11px] leading-relaxed text-sky-200/80">
          {t.aboutDisclaimer}
        </div>
      </div>

      {/* Privacy Policy Button (bottom of About screen) */}
      <button
        type="button"
        data-testid="open-privacy-policy-btn"
        onClick={() => setIsPrivacyPolicyOpen(true)}
        className="w-full bg-[#141A29]/75 hover:bg-[#1B2338]/85 backdrop-blur-2xl rounded-3xl p-4 border border-white/15 shadow-[0_16px_44px_rgba(0,0,0,0.55)] flex items-center justify-center gap-2.5 text-xs font-bold text-sky-200 hover:text-white transition-all cursor-pointer active:scale-[0.99]"
      >
        <FileText className="w-4 h-4 text-[#FF5E3A]" />
        <span>{lang === 'en' ? 'Privacy Policy' : 'Політика конфіденційності'}</span>
      </button>

      {/* Privacy Policy Popup Modal */}
      {isPrivacyPolicyOpen && (
        <div
          data-testid="privacy-policy-modal"
          className="fixed inset-0 z-50 bg-black/75 backdrop-blur-md flex items-center justify-center p-4"
          onClick={() => setIsPrivacyPolicyOpen(false)}
        >
          <div
            className="bg-[#141A29]/95 backdrop-blur-2xl border border-white/20 rounded-3xl p-5 max-w-md w-full max-h-[82vh] shadow-[0_20px_60px_rgba(0,0,0,0.75)] text-white relative flex flex-col gap-3"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between gap-3 pb-3 border-b border-white/15 shrink-0">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#FF5E3A] flex items-center justify-center text-white shadow-md shadow-[#FF5E3A]/30">
                  <FileText className="w-4 h-4" />
                </div>
                <h3 className="text-sm font-bold text-white tracking-tight">
                  {lang === 'en' ? 'Privacy Policy' : 'Політика конфіденційності'}
                </h3>
              </div>
              <button
                type="button"
                data-testid="close-privacy-policy-btn"
                onClick={() => setIsPrivacyPolicyOpen(false)}
                className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white/70 hover:text-white flex items-center justify-center transition-all cursor-pointer border border-white/10"
                aria-label="Close"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto pr-1 rounded-2xl bg-white/[0.04] border border-white/10 p-3.5 select-text">
              <pre className="whitespace-pre-wrap break-words font-sans text-[11px] leading-relaxed text-zinc-200">
                {privacyPolicyMarkdown}
              </pre>
            </div>

            <button
              type="button"
              onClick={() => setIsPrivacyPolicyOpen(false)}
              className="w-full py-3 px-4 rounded-2xl bg-white hover:bg-zinc-200 text-black font-bold text-xs transition-all shadow-lg text-center cursor-pointer shrink-0"
            >
              {lang === 'en' ? 'Got it' : 'Зрозуміло'}
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
