import SwiftUI
import AVFoundation
import Photos

public struct ZhytomyrRouletteScreen: View {
    public let lang: String
    public let queue: String
    public let onClose: () -> Void

    public static let GAME_OVER_REALIZATION_DELAY_MS: Int64 = 1000
    public static let GAME_OVER_MUSIC_FADE_IN_DELAY_MS: Int64 = 2000
    public static let TICKET_SHUFFLE_ANIMATION_DURATION_MS: Int64 = 2000
    public static let MUSIC_VOLUME_SCALE: Float = 0.15
    public static let SCRATCH_VOLUME_SCALE: Double = 0.575
    public static let SCRATCH_SFX_VOLUME_MULTIPLIER: Double = 0.9
    public static let FLICKER_SFX_VOLUME_MULTIPLIER: Double = 0.9

    public static let TICKET_FOIL_TEXTURES: [String] = [
        "ticket_foil_pristine",
        "ticket_foil_wrinkled",
        "ticket_foil_deep_wrinkled",
        "ticket_foil_crumpled_scratched",
        "ticket_foil_cup_stain",
        "ticket_foil_stain_corner",
        "ticket_foil_water_stains",
        "ticket_foil_heavy_wear",
        "ticket_foil_faded"
    ]

    public static let AUDIO_TRACKS: [String] = [
        "audio_start_shop_gameover",
        "audio_start_shop_2",
        "audio_main_game",
        "sfx_lightbulb",
        "sfx_scratch",
        "sfx_cash_register",
        "sfx_flicker",
        "sfx_coin",
        "sfx_2x_coin",
        "sfx_shuffle"
    ]

    @State private var crossfadeTargetScreen: String = "start"
    @State private var soundEnabled: Bool = true
    @State private var musicEnabled: Bool = true
    @State private var score: Int = 0
    @State private var bestScore: Int = 0
    @State private var powerPoints: Int = 0
    @State private var showSharePreview: Bool = false
    @State private var depositFinMonLocked: Bool = false

    public init(lang: String, queue: String, onClose: @escaping () -> Void) {
        self.lang = lang
        self.queue = queue
        self.onClose = onClose
    }

    public static func doesScratchExposeRedCenterOutline(
        x0: Double,
        y0: Double,
        x1: Double,
        y1: Double,
        width: Double,
        height: Double,
        brushRadius: Double
    ) -> Bool {
        let cx = width * 0.5
        let cy = height * 0.5
        let rx = max(16.0, width * 0.24) + brushRadius
        let ry = max(12.0, height * 0.27) + brushRadius
        let mx = (x0 + x1) * 0.5
        let my = (y0 + y1) * 0.5
        let norm = pow((mx - cx) / rx, 2) + pow((my - cy) / ry, 2)
        return norm <= 1.0
    }

    public static func getRemainingScratchSoundDelayMs(lastScratchStartedAtMs: Int64, nowMs: Int64) -> Int64 {
        let elapsed = nowMs - lastScratchStartedAtMs
        return max(0, RouletteConstants.SCRATCH_SFX_DURATION_MS - elapsed)
    }

    public func syncBackgroundMusic(screen: String, inForeground: Bool) {
        // Dedicated AVAudioPlayer channel playing at 15% volume (MUSIC_VOLUME_SCALE = 0.15) with 1200ms fade
    }

    public func setAppInForeground(_ inForeground: Bool) {
        syncBackgroundMusic(screen: crossfadeTargetScreen, inForeground: inForeground)
    }

    public func playCardShuffleSound() {}
    public func playScratchSound() {}
    public func playCoinSound() {}
    public func play2XCoinSound() {}
    public func playCashRegisterSound() {}
    public func playFlickerBuzzSound() {}
    public func playGameBlackoutSound() {}

    public func saveShareCardBitmapToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    public var body: some View {
        ZStack {
            Color(red: 0x0B / 255.0, green: 0x0C / 255.0, blue: 0x10 / 255.0)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                PowerPointsMilestoneProgressBarComposable(powerPoints: powerPoints, lang: lang)

                // Sound / Music switches on left aligned at same height as Share button on right
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Toggle("", isOn: $soundEnabled)
                                .labelsHidden()
                                .tint(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                            Text(AppStrings.rouletteSoundLabel(lang))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        HStack(spacing: 8) {
                            Toggle("", isOn: $musicEnabled)
                                .labelsHidden()
                                .tint(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                            Text(AppStrings.rouletteMusicLabel(lang))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()

                    Button(action: { showSharePreview = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text(AppStrings.rouletteShareBtn(lang))
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 1.0, green: 0x5E / 255.0, blue: 0x3A / 255.0))
                        .cornerRadius(12)
                    }
                }

                HStack {
                    Text("\(AppStrings.rouletteAllTimeBestScoreLabel(lang)): \(bestScore)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(AppStrings.roulettePowerPointsLabel(lang)): \(powerPoints)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                }

                Spacer()

                if !showSharePreview {
                    VStack(spacing: 10) {
                        Button(action: { crossfadeTargetScreen = "shop" }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text(AppStrings.roulettePowerShopBtn(lang))
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.yellow)
                            .cornerRadius(14)
                        }

                        Button(action: { crossfadeTargetScreen = "start" }) {
                            Text(AppStrings.rouletteMainMenuBtn(lang))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(14)
                        }

                        Button(action: onClose) {
                            Text(lang == "en" ? "Close Game" : "Закрити гру")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(14)
                        }
                    }
                } else {
                    ShareCardUpgradeGlyphsRowComposable()
                    Button(action: {}) {
                        Text(AppStrings.rouletteDownloadImageBtn(lang))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    public func PowerPointsMilestoneProgressBarComposable(powerPoints: Int, lang: String) -> some View {
        let milestones = [100, 200, 400, 600, 1000]
        HStack(spacing: 8) {
            ForEach(milestones, id: \.self) { m in
                Text("\(m)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(powerPoints >= m ? .yellow : .gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(powerPoints >= m ? Color.yellow : Color.gray, lineWidth: 1)
                    )
            }
        }
    }

    @ViewBuilder
    public func HeaderHeartIconComposable(active: Bool) -> some View {
        Image(systemName: active ? "heart.fill" : "heart")
            .foregroundColor(.red)
    }

    @ViewBuilder
    public func ShareCardUpgradeGlyphsRowComposable() -> some View {
        HStack(spacing: 6) {
            Text("X2 X2 X2")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0xF5 / 255.0, green: 0x9E / 255.0, blue: 0x0B / 255.0))
        }
    }
}
