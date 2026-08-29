import SwiftUI

/// Horizontally scrolling section of insight cards with icons, metrics, and descriptions.
struct DailyInsightsSection: View {

    let insights: [InsightCard]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(
                title: Strings.Dashboard.dailyInsightsTitle,
                subtitle: Strings.Dashboard.dailyInsightsSubtitle
            )

            if insights.isEmpty {
                VStack(spacing: DesignTokens.Spacing.md) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: DesignTokens.IconSize.xl, weight: .medium))
                        .foregroundStyle(.white.opacity(0.3))

                    Text("Start a session to see your insights")
                        .font(DesignTokens.Typography.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.xxl)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        ForEach(insights) { insight in
                            insightCard(insight)
                        }
                    }
                }
            }
        }
    }

    private func insightCard(_ insight: InsightCard) -> some View {
        ZStack {
            // Very faint background icon - Opal style
            Image(systemName: insight.icon)
                .font(.system(size: 44))
                .foregroundStyle(insight.color.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(10)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: insight.icon)
                        .foregroundStyle(insight.color)
                    Text(insight.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(insight.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(3)

                Text(insight.metric)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))

                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)

                Text("View Details")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(14)
        }
        .frame(width: 165, height: 195)
        .glassEffect(in: .rect(cornerRadius: 20))
    }
}
