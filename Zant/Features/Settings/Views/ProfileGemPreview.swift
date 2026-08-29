import SwiftUI

/// Gem collection preview showing up to 4 earned gem types with a "View All" button.
struct ProfileGemPreview: View {

    let earnedGemTypes: [GemType]
    var onViewAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: Strings.Profile.collection) {
                Button {
                    onViewAll()
                } label: {
                    Text(Strings.Profile.viewAll)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.accent)
                }
            }

            HStack(spacing: DesignTokens.Spacing.md) {
                if earnedGemTypes.isEmpty {
                    Text(Strings.Profile.completeSessionsForGems)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.textTertiary)
                } else {
                    ForEach(earnedGemTypes.prefix(4), id: \.self) { gem in
                        GemView(type: gem, size: 44, isEarned: true)
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(DesignTokens.Colors.surfaceGlass)
            )
        }
    }
}
