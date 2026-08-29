import SwiftUI

/// Reusable settings section wrapper with uppercase title and rounded glass background.
/// Used across all settings sections in ProfileView.
struct SettingsSection<Content: View>: View {

    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(0.5)
                .padding(.leading, DesignTokens.Spacing.xs)

            content
                .glassEffect(in: .rect(cornerRadius: DesignTokens.Radius.md))
        }
    }
}
