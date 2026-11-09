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
            VStack(spacing: 14) {
                // App Identity & Version Card
                VStack(spacing: 6) {
                    Text(AppStrings.APP_NAME)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("v\(Self.APP_VERSION) · iOS 17.0+")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // Charity / Благодійність і Пожертви Section
                VStack(alignment: .leading, spacing: 10) {
                    Text(AppStrings.donationsSectionTitle(lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)

                    ForEach(donations) { item in
                        if let url = URL(string: item.url) {
                            Link(destination: url) {
                                HStack {
                                    Text(item.title)
                                        .font(.system(size: 13, weight: .semibold))
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
                .padding(16)
                .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.75))
                .cornerRadius(24)

                // Zhytomyr Roulette Launch Button (right after Donations block)
                Button(action: onOpenRoulette) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text(AppStrings.rouletteLaunchButton(lang))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(16)
                    .background(Color(red: 0x14 / 255.0, green: 0x1A / 255.0, blue: 0x29 / 255.0).opacity(0.85))
                    .cornerRadius(24)
                }

                // Links Card: 1) ZTOE website, 2) Світло в Житомирі на Github (README.md), 3) GitHub Issues
                VStack(alignment: .leading, spacing: 10) {
                    if let ztoeUrl = URL(string: AppStrings.DEFAULT_ZTOE_URL) {
                        Link(destination: ztoeUrl) {
                            Text("АТ «Житомиробленерго» (ztoe.com.ua)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }

                    if let readmeUrl = URL(string: AppStrings.ABOUT_GITHUB_README_URL) {
                        Link(destination: readmeUrl) {
                            Text(AppStrings.aboutGithubRepoLabel(lang))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }

                    if let issuesUrl = URL(string: AppStrings.ABOUT_ISSUES_URL) {
                        Link(destination: issuesUrl) {
                            Text("https://github.com/IgorZaharov/Android-ZTBlackoutPreWarning/issues")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
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
