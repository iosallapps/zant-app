import Foundation
import SwiftUI

/// Circular progress ring used for Focus Score, session timer, and goal progress.
///
/// Usage:
/// ```swift
/// ZantProgressRing(progress: 0.75, score: 75)
/// ZantProgressRing(progress: 0.5, lineWidth: 8, size: 60)
/// ZantProgressRing(progress: 0.85, score: 85, showOuterGlow: true)
/// ```
struct ZantProgressRing: View {

    let progress: Double  // 0.0 to 1.0
    var score: Int?
    var lineWidth: CGFloat = 12
    var size: CGFloat = 160
    var showLabel: Bool = true
    var showOuterGlow: Bool = false
    var overrideColor: Color? = nil

    // MARK: - Animation State

    @State private var outerRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    // MARK: - Derived

    private var progressColor: Color {
        if let overrideColor { return overrideColor }
        let pct = progress * 100
        if pct >= 80 { return DesignTokens.Colors.scoreGreen }
        if pct >= 50 { return DesignTokens.Colors.scoreYellow }
        return DesignTokens.Colors.scoreRed
    }

    /// Lighter tint of the score color for the gradient stroke endpoint.
    private var progressColorLight: Color {
        progressColor.opacity(0.55)
    }

    /// Gradient used for the progress arc stroke.
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [progressColor, progressColorLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Position (in the ring's coordinate space) of the progress arc tip.
    private var tipPosition: CGPoint {
        let angle = Angle.degrees(360 * min(progress, 1.0) - 90)
        let radius = (size - lineWidth) / 2
        return CGPoint(
            x: size / 2 + radius * CGFloat(Foundation.cos(angle.radians)),
            y: size / 2 + radius * CGFloat(Foundation.sin(angle.radians))
        )
    }

    // MARK: - Body

    var body: some View {
        ZStack {

            // ── Radial glow behind the ring ──
            if showOuterGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [progressColor.opacity(0.25), .clear],
                            center: .center,
                            startRadius: size * 0.15,
                            endRadius: size * 0.6
                        )
                    )
                    .frame(width: size * 1.3, height: size * 1.3)
                    .blur(radius: size * 0.12)
            }

            // ── Rotating outer decorative ring ──
            if showOuterGlow {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                DesignTokens.Colors.accent.opacity(0.0),
                                DesignTokens.Colors.accentLight.opacity(0.25),
                                DesignTokens.Colors.accent.opacity(0.15),
                                DesignTokens.Colors.accentLight.opacity(0.0),
                            ],
                            center: .center
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: size + lineWidth + 10, height: size + lineWidth + 10)
                    .rotationEffect(.degrees(outerRotation))
                    .onAppear {
                        withAnimation(
                            .linear(duration: 12)
                            .repeatForever(autoreverses: false)
                        ) {
                            outerRotation = 360
                        }
                    }
            }

            // ── Inner subtle pulse fill ──
            if showOuterGlow {
                Circle()
                    .fill(progressColor.opacity(0.04))
                    .frame(width: size - lineWidth - 4, height: size - lineWidth - 4)
                    .scaleEffect(pulseScale)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 3)
                            .repeatForever(autoreverses: true)
                        ) {
                            pulseScale = 1.04
                        }
                    }
            }

            // ── Background track ring ──
            Circle()
                .stroke(
                    progressColor.opacity(0.15),
                    lineWidth: lineWidth
                )

            // ── Progress arc (gradient stroke) ──
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(DesignTokens.Animation.smooth, value: progress)

            // ── Glow dot at the arc tip ──
            if progress > 0.01 {
                Circle()
                    .fill(progressColor)
                    .frame(width: lineWidth * 0.55, height: lineWidth * 0.55)
                    .blur(radius: lineWidth * 0.45)
                    .position(tipPosition)
                    .animation(DesignTokens.Animation.smooth, value: progress)
            }

            // ── Center label ──
            if showLabel, let score {
                VStack(spacing: DesignTokens.Spacing.xxs) {
                    Text("\(score)")
                        .font(DesignTokens.Typography.scoreLarge)
                        .foregroundStyle(progressColor)
                        .contentTransition(.numericText())

                    Text("Focus Score")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: DesignTokens.Spacing.xxl) {
        ZantProgressRing(progress: 0.85, score: 85)
        ZantProgressRing(progress: 0.5, score: 50, size: 80)
        ZantProgressRing(progress: 0.3, score: 30, lineWidth: 6, size: 60)
    }
}

#Preview("Premium Glow") {
    ZantProgressRing(progress: 0.85, score: 85, showOuterGlow: true)
        .padding(DesignTokens.Spacing.huge)
        .background(DesignTokens.Gradients.deepBackground)
}
