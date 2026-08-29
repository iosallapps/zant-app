import SwiftUI

// MARK: - Streak Banner View

struct StreakBannerView: View {

    let streakDays: Int
    let nextMilestone: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Flame icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Text("🔥")
                        .font(.system(size: 32))
                }

                // Streak info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("\(streakDays)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Day Streak")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    if streakDays > 0 {
                        Text(motivationalMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    } else {
                        Text("Start your first session today!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                Spacer()

                // Progress indicator
                if streakDays > 0 {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .background(
                LinearGradient(
                    colors: streakDays > 0
                        ? [Color.orange.opacity(0.15), Color.orange.opacity(0.05)]
                        : [Color.white.opacity(0.05), Color.white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(
                        streakDays > 0
                            ? Color.orange.opacity(0.3)
                            : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helper

    private var motivationalMessage: String {
        if streakDays >= nextMilestone {
            return "Amazing! Keep the momentum going!"
        } else {
            let remaining = nextMilestone - streakDays
            return "\(remaining) more \(remaining == 1 ? "day" : "days") to \(nextMilestone)-day milestone"
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            StreakBannerView(streakDays: 0, nextMilestone: 3) {}

            StreakBannerView(streakDays: 5, nextMilestone: 7) {}

            StreakBannerView(streakDays: 21, nextMilestone: 30) {}
        }
        .padding()
    }
}
