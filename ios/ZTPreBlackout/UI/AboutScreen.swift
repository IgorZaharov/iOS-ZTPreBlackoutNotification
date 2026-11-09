import SwiftUI

public struct AboutScreen: View {
    public let lang: String
    public let donations: [DonationItem]
    public let onOpenRoulette: () -> Void

    public static let APP_VERSION = "1.3.3"

    public init(
        lang: String,
        donations: [DonationItem] = DonationsRepository.DEFAULT_DONATIONS,
        onOpenRoulette: @escaping () -> Void
    ) {
        self.lang = lang
        self.donations = donations
        self.onOpenRoulette = onOpenRoulette
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // 1. App Identity & Version Card
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                            .frame(width: 60, height: 60)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(AppStrings.APP_NAME)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text(AppStrings.aboutSubtitle(lang))
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                    Text("v\(Self.APP_VERSION)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.10))
                        .cornerRadius(12)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 2. App Description Card
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppStrings.aboutDescTitle(lang).uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))

                    Text(AppStrings.aboutDescText(lang))
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0xE2 / 255.0, green: 0xE8 / 255.0, blue: 0xF0 / 255.0))
                        .lineSpacing(3)

                    Text(AppStrings.aboutDesktopNotice(lang))
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.8))
                        .lineSpacing(3)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 3. Developer & GitHub Links Card
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppStrings.aboutLinksTitle(lang).uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))

                    if let profileUrl = URL(string: "https://github.com/IgorZaharov") {
                        Link(destination: profileUrl) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(AppStrings.devProfile(lang))
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("github.com/IgorZaharov")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }
                    }

                    if let readmeUrl = URL(string: AppStrings.ABOUT_GITHUB_README_URL) {
                        Link(destination: readmeUrl) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(AppStrings.aboutGithubRepoLabel(lang))
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/blob/main/README.md")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }
                    }

                    if let issuesUrl = URL(string: AppStrings.ABOUT_ISSUES_URL) {
                        Link(destination: issuesUrl) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(AppStrings.repoIssues(lang))
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("github.com/IgorZaharov/iOS-ZTPreBlackoutNotification/issues")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 4. Charity / Благодійність і Пожертви Section (Opens externally in Safari per Apple Guideline 3.2.1(vi))
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppStrings.donationsSectionTitle(lang))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.7))

                    ForEach(donations) { item in
                        if let url = URL(string: item.url) {
                            Link(destination: url) {
                                HStack {
                                    Text(item.title)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(14)
                            }
                        }
                    }
                }
                .padding(18)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // 5. Zhytomyr Roulette Launch Button (right after Donations block)
                Button(action: onOpenRoulette) {
                    Text(AppStrings.rouletteLaunchButton(lang))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0xFD / 255.0, green: 0xE6 / 255.0, blue: 0x8A / 255.0))
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                        .cornerRadius(24)
                }

                // 6. Disclaimer Card (Apple Guideline 5.2.2 compliance: independent utility notice)
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.20))
                            .frame(width: 36, height: 36)
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(.yellow)
                    }
                    Text(AppStrings.disclaimerText(lang))
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0xBA / 255.0, green: 0xE6 / 255.0, blue: 0xFD / 255.0).opacity(0.8))
                        .lineSpacing(2)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
    }
}
