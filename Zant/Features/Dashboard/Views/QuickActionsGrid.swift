import SwiftUI

/// 2x2 grid of quick action cards: Start Session, Block Apps, Weekly Report, Daily Challenge.
struct QuickActionsGrid: View {

    var onStartSession: () -> Void
    var onBlockApps: () -> Void
    var onBlockTemplates: () -> Void
    var onWeeklyReport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: Strings.Dashboard.quickActions)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                ],
                spacing: DesignTokens.Spacing.md
            ) {
                quickActionCard(icon: "timer", title: Strings.Dashboard.startSession, action: onStartSession)
                quickActionCard(icon: "lock.shield.fill", title: Strings.Dashboard.blockApps, action: onBlockApps)
                quickActionCard(icon: "square.grid.2x2.fill", title: "Block Templates", action: onBlockTemplates)
                quickActionCard(icon: "chart.bar.fill", title: Strings.Dashboard.weeklyReport, action: onWeeklyReport)
            }
        }
    }

    private func quickActionCard(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.light()
            action()
        } label: {
            VStack(spacing: DesignTokens.Spacing.md) {
                Spacer()

                Image(systemName: icon)
                    .font(.system(size: DesignTokens.IconSize.lg, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.xl)
            .glassEffect(in: .rect(cornerRadius: 20))
        }
        .buttonStyle(QuickActionButtonStyle())
    }
}

// MARK: - Button Style

private struct QuickActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(DesignTokens.Animation.quick, value: configuration.isPressed)
    }
}
