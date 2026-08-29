import SwiftUI

/// Subscription section showing current plan, upgrade prompt, and restore purchases.
struct SubscriptionSection: View {

    let isPremium: Bool
    @Binding var isRestoringPurchases: Bool
    var onUpgrade: () -> Void
    var onRestore: () -> Void

    var body: some View {
        SettingsSection(title: Strings.Profile.subscription) {
            VStack(spacing: 0) {
                Button {
                    onUpgrade()
                } label: {
                    subscriptionRow
                }
                .buttonStyle(SettingsRowButtonStyle())
                SectionDivider()
                Button {
                    onRestore()
                } label: {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        if isRestoringPurchases {
                            ProgressView()
                                .tint(DesignTokens.Colors.textPrimary)
                                .controlSize(.small)
                                .padding(.horizontal, DesignTokens.Spacing.lg)
                                .padding(.vertical, DesignTokens.Spacing.md)
                        } else {
                            SettingsRow(icon: "arrow.clockwise", title: Strings.Profile.restorePurchases, showChevron: false)
                        }
                    }
                }
                .buttonStyle(SettingsRowButtonStyle())
                .disabled(isRestoringPurchases)
            }
        }
    }

    private var subscriptionRow: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.surfaceGlassLight)
                    .frame(width: 30, height: 30)
                Image(systemName: "crown.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.iconNeutral)
            }

            Text(Strings.Profile.currentPlan)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Colors.textPrimary)

            Spacer()

            Text(isPremium ? Strings.General.premium : Strings.General.free)
                .font(DesignTokens.Typography.subheadline)
                .foregroundStyle(DesignTokens.Colors.textSecondary)

            if !isPremium {
                Text(Strings.General.upgrade)
                    .font(DesignTokens.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .glassEffect(
                        .regular.tint(DesignTokens.Colors.glassTint).interactive(),
                        in: .capsule
                    )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }
}
