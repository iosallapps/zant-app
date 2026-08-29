import SwiftUI

/// A reusable settings row with icon, title, optional value, chevron, and "Coming Soon" badge.
/// Used across General, Blocking, Subscription, About, and Danger Zone sections.
struct SettingsRow: View {

    let icon: String
    let title: String
    var value: String? = nil
    var showChevron: Bool = true
    var comingSoon: Bool = false

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.surfaceGlassLight)
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: DesignTokens.IconSize.sm, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.iconNeutral)
            }

            Text(title)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Colors.textPrimary)

            if comingSoon {
                Text("Soon")
                    .font(DesignTokens.Typography.badge)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xxs)
                    .background(DesignTokens.Colors.divider)
                    .clipShape(Capsule())
            }

            Spacer()

            if let value {
                Text(value)
                    .font(DesignTokens.Typography.subheadline)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(DesignTokens.Typography.footnote)
                    .foregroundStyle(DesignTokens.Colors.textTertiary)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .opacity(comingSoon ? 0.5 : 1.0)
    }
}

/// Press-feedback style for buttons containing a SettingsRow.
struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
