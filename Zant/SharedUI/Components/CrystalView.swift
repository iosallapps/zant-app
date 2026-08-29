import SwiftUI

// MARK: - CrystalType Visual Properties

extension CrystalType {

    var glowColor: Color {
        switch tier {
        case .common: Color.white
        case .uncommon: Color.cyan
        case .rare: Color.purple
        case .epic: Color.orange
        case .legendary: Color.red
        }
    }
}

// MARK: - Crystal View

/// Displays a crystal with image, glow effect, and earned/unearned states
struct CrystalView: View {

    let crystal: CrystalType
    var size: CGFloat = 48
    var isEarned: Bool = true

    var body: some View {
        ZStack {
            // Atmospheric glow
            if isEarned {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                crystal.glowColor.opacity(0.45),
                                crystal.glowColor.opacity(0.12),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.7
                        )
                    )
                    .frame(width: size * 1.6, height: size * 1.6)
                    .blur(radius: size * 0.15)
            }

            // Crystal image
            Image(crystal.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.85, height: size * 0.85)
                .saturation(isEarned ? 1.2 : 0)
                .opacity(isEarned ? 1 : 0.25)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        VStack(spacing: DesignTokens.Spacing.xxxl) {
            // Tier 1 - Common
            HStack(spacing: DesignTokens.Spacing.xl) {
                ForEach([CrystalType.clearQuartz, .roseQuartz, .citrine, .moonstone], id: \.self) { crystal in
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        CrystalView(crystal: crystal, size: 56, isEarned: true)
                        Text(crystal.displayName)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(crystal.tier.displayName)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }

            // Tier 3 - Rare (larger)
            HStack(spacing: DesignTokens.Spacing.xxxl) {
                ForEach([CrystalType.amethyst, .labradorite, .tigersEye, .lapisLazuli], id: \.self) { crystal in
                    CrystalView(crystal: crystal, size: 80, isEarned: true)
                }
            }

            // Tier 5 - Legendary (comparison earned vs unearned)
            HStack(spacing: DesignTokens.Spacing.xl) {
                CrystalView(crystal: .alexandrite, size: 100, isEarned: true)
                CrystalView(crystal: .blackObsidian, size: 100, isEarned: false)
            }
        }
    }
}
