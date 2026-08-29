import SwiftUI

/// Danger zone section with delete all data action.
struct DangerZoneSection: View {

    var onDeleteAllData: () -> Void

    var body: some View {
        SettingsSection(title: Strings.Profile.dangerZone) {
            Button {
                onDeleteAllData()
            } label: {
                dangerRow
            }
            .buttonStyle(SettingsRowButtonStyle())
        }
    }

    private var dangerRow: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.error.opacity(0.12))
                    .frame(width: 30, height: 30)
                Image(systemName: "trash.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.error)
            }

            Text(Strings.Profile.deleteAllData)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Colors.error)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }
}
