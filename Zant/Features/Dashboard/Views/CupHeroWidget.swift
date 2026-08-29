import SwiftUI

/// Interactive 3D Cup Hero Widget - Centerpiece of dashboard
/// Shows current streak level with beautiful animated cup (Opal-inspired)
struct CupHeroWidget: View {

    // MARK: - Properties

    let currentStreak: Int
    let earnedCrystals: [CrystalType]
    let onTap: () -> Void

    // MARK: - State

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.3

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background glow layers
                glowLayers

                // Main cup container
                cupContainer

                // Streak badge
                streakBadge
            }
            .frame(height: DesignTokens.ComponentSize.widgetHeight)
        }
        .buttonStyle(.plain)
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Glow Layers

    private var glowLayers: some View {
        ZStack {
            // Outer glow pulse
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            currentCup.glowColor.opacity(pulseOpacity),
                            currentCup.glowColor.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: DesignTokens.ComponentSize.glowRadiusOuter, height: DesignTokens.ComponentSize.glowRadiusOuter)
                .blur(radius: 40)

            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            currentCup.glowColor.opacity(0.4),
                            currentCup.glowColor.opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: DesignTokens.ComponentSize.glowRadiusInner, height: DesignTokens.ComponentSize.glowRadiusInner)
                .blur(radius: 20)
        }
    }

    // MARK: - Cup Container

    private var cupContainer: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            // Particle sparkles (above cup)
            particleSparkles

            // The cup
            ZStack {
                // Shadow/depth
                Image(currentCup.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DesignTokens.ComponentSize.cupImageLarge, height: DesignTokens.ComponentSize.cupImageLarge)
                    .offset(y: 4)
                    .opacity(0.3)
                    .blur(radius: 8)

                // Main cup
                Image(currentCup.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DesignTokens.ComponentSize.cupImageLarge, height: DesignTokens.ComponentSize.cupImageLarge)
                    .saturation(1.3)
                    .brightness(0.05)
                    .shadow(color: currentCup.glowColor.opacity(0.6), radius: 30, x: 0, y: 10)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .scaleEffect(scale)
            }

            // Cup name
            VStack(spacing: DesignTokens.Spacing.xs + 2) {
                Text(currentCup.displayName)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(currentCup.tier.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(currentCup.glowColor)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(currentCup.glowColor.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Particle Sparkles

    private var particleSparkles: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(currentCup.glowColor)
                    .frame(width: CGFloat.random(in: 3...6), height: CGFloat.random(in: 3...6))
                    .offset(
                        x: cos(Double(index) * .pi / 4) * 80,
                        y: sin(Double(index) * .pi / 4) * 80
                    )
                    .opacity(0.6)
                    .blur(radius: 1)
            }
        }
        .rotationEffect(.degrees(rotation * 0.5))
        .opacity(0.7)
    }

    // MARK: - Streak Badge

    private var streakBadge: some View {
        VStack {
            HStack {
                Spacer()

                VStack(spacing: DesignTokens.Spacing.xs) {
                    HStack(spacing: DesignTokens.Spacing.xs + 2) {
                        Text("🔥")
                            .font(.title3)
                        Text("\(currentStreak)")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }

                    Text("Day Streak")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.trailing, DesignTokens.Spacing.xl)

            Spacer()
        }
        .padding(.top, DesignTokens.Spacing.xl)
    }

    // MARK: - Computed

    private var currentCup: CrystalType {
        // Determine cup based on streak level
        let streakLevel = min(max(currentStreak / 5, 1), 20) // Every 5 days unlocks next tier
        return CrystalType(rawValue: streakLevel) ?? .clearQuartz
    }

    // MARK: - Animations

    private func startAnimations() {
        // Slow rotation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // Gentle pulse
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            scale = 1.05
            pulseOpacity = 0.5
        }
    }
}

// MARK: - Compact Version (for smaller spaces)

struct CupHeroWidgetCompact: View {
    let currentStreak: Int
    let earnedCrystals: [CrystalType]
    let onTap: () -> Void

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.xl) {
                // Cup
                ZStack {
                    // Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    currentCup.glowColor.opacity(0.3),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: DesignTokens.ComponentSize.cupImageMedium, height: DesignTokens.ComponentSize.cupImageMedium)
                        .blur(radius: 20)

                    Image(currentCup.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: DesignTokens.ComponentSize.cupImageSmall, height: DesignTokens.ComponentSize.cupImageSmall)
                        .saturation(1.2)
                        .shadow(color: currentCup.glowColor.opacity(0.5), radius: 15)
                        .rotation3DEffect(
                            .degrees(rotation),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .scaleEffect(scale)
                }

                // Info
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    HStack(spacing: DesignTokens.Spacing.xs + 2) {
                        Text("🔥")
                        Text("\(currentStreak) Day Streak")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }

                    Text(currentCup.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(currentCup.tier.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(currentCup.glowColor)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xxs + 1)
                        .background(currentCup.glowColor.opacity(0.2))
                        .clipShape(Capsule())
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(DesignTokens.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.03
            }
        }
    }

    private var currentCup: CrystalType {
        let streakLevel = min(max(currentStreak / 5, 1), 20)
        return CrystalType(rawValue: streakLevel) ?? .clearQuartz
    }
}

// MARK: - Preview

#Preview("Hero Widget") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            CupHeroWidget(
                currentStreak: 21,
                earnedCrystals: [],
                onTap: {
                    print("Cup tapped")
                }
            )
            .padding(DesignTokens.Spacing.xl)
        }
    }
}

#Preview("Compact Widget") {
    ZStack {
        Color.black.ignoresSafeArea()

        CupHeroWidgetCompact(
            currentStreak: 7,
            earnedCrystals: [],
            onTap: {
                print("Cup tapped")
            }
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
