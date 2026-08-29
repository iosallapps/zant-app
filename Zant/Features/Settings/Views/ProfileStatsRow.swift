import SwiftUI

/// Horizontal row showing Total Sessions, Focus Time, and Best Streak with animated numeric transitions.
struct ProfileStatsRow: View {

    let animatedSessions: Int
    let animatedHours: Int
    let animatedStreak: Int

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            statItem(value: "\(animatedSessions)", label: Strings.Profile.totalSessions)
            statItem(value: "\(animatedHours)h", label: Strings.Profile.focusTime)
            statItem(value: "\(animatedStreak)", label: Strings.Profile.bestStreak, unit: Strings.Profile.days)
        }
        .glassCard()
        .shadow(color: Color.black.opacity(0.3), radius: 12, y: 4)
    }

    private func statItem(value: String, label: String, unit: String? = nil) -> some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.xxs) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                if let unit {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
