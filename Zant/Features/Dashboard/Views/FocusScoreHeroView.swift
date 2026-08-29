import SwiftUI

/// Large focus score hero section with progress ring, score message, and inline stat bar.
struct FocusScoreHeroView: View {

    let focusScore: Int
    let animatedScore: Int
    let animatedScreenTime: Int
    let animatedSessions: Int
    let scoreColor: Color
    let scoreMessage: String
    var formatTime: (Int) -> String

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Subtle glow
                Circle()
                    .fill(scoreColor.opacity(0.08))
                    .blur(radius: 40)
                    .frame(width: 200, height: 200)

                ZantProgressRing(
                    progress: Double(focusScore) / 100.0,
                    score: animatedScore,
                    lineWidth: 12,
                    size: 180,
                    showOuterGlow: false
                )
            }
            .frame(height: 200)

            Text(scoreMessage)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))

            HStack(spacing: 0) {
                inlineStat(label: Strings.Dashboard.focus, value: "\(animatedScore)%")
                inlineDivider
                inlineStat(label: Strings.Dashboard.screenTime, value: formatTime(animatedScreenTime))
                inlineDivider
                inlineStat(label: Strings.Dashboard.sessions, value: "\(animatedSessions)")
            }
            .padding(16)
            .glassEffect(in: .rect(cornerRadius: 20))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private Helpers

    private func inlineStat(label: String, value: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .contentTransition(.numericText())

            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(DesignTokens.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var inlineDivider: some View {
        Rectangle()
            .fill(DesignTokens.Colors.divider)
            .frame(width: 1, height: 36)
    }
}
