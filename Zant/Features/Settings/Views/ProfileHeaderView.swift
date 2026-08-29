import SwiftUI

/// Rotating avatar with angular gradient ring, person icon, level badge, title, and member-since label.
struct ProfileHeaderView: View {

    let currentLevel: Int
    let levelTitle: String
    let memberSinceString: String
    @Binding var avatarRotation: Double

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.accent.opacity(0.15))
                    .blur(radius: 30)
                    .frame(width: 130, height: 130)

                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                DesignTokens.Colors.accent.opacity(0.0),
                                DesignTokens.Colors.accent.opacity(0.6),
                                DesignTokens.Colors.accentLight.opacity(0.4),
                                DesignTokens.Colors.accent.opacity(0.0),
                            ],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(avatarRotation))

                Circle()
                    .fill(DesignTokens.Colors.accent.gradient)
                    .frame(width: 84, height: 84)

                Image(systemName: "person.fill")
                    .font(.system(size: DesignTokens.IconSize.xxl, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.textPrimary)

                // Level badge
                ZStack {
                    Circle()
                        .fill(DesignTokens.Colors.accent)
                        .frame(width: 28, height: 28)
                    Circle()
                        .stroke(DesignTokens.Colors.textTertiary, lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                    Text("\(currentLevel)")
                        .font(DesignTokens.Typography.badge)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                }
                .offset(x: 32, y: 32)
            }

            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(levelTitle)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("\(Strings.Rewards.levelPrefix) \(currentLevel)")
                    .font(.headline)
                    .foregroundStyle(DesignTokens.Colors.accent)

                Text(memberSinceString)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xl)
    }
}
