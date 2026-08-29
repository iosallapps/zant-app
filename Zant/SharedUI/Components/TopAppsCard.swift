import SwiftUI

/// Card showing most used apps with usage time
struct TopAppsCard: View {

    let apps: [AppUsageInfo]
    let title: String

    init(apps: [AppUsageInfo], title: String = "Your Most Used Apps") {
        self.apps = apps
        self.title = title
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.accent)

                Text(title)
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("Today")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            // App list
            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(Array(apps.prefix(5).enumerated()), id: \.element.id) { index, app in
                    appRow(app: app, rank: index + 1)

                    if index < min(4, apps.count - 1) {
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                }
            }

            if apps.isEmpty {
                emptyState
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .glassEffect(in: .rect(cornerRadius: DesignTokens.Radius.xl))
    }

    // MARK: - Subviews

    private func appRow(app: AppUsageInfo, rank: Int) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Rank badge
            Text("\(rank)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 20)

            // App icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                rankColor(rank).opacity(0.3),
                                rankColor(rank).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: app.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(rankColor(rank))
            }

            // App info
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.white)

                Text(app.category)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Usage time
            VStack(alignment: .trailing, spacing: 2) {
                Text(app.formattedUsage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(rankColor(rank))

                if app.usageMinutes > 60 {
                    Text("⚠️")
                        .font(.system(size: 12))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.3))

            Text("No usage data yet")
                .font(DesignTokens.Typography.body)
                .foregroundStyle(.white.opacity(0.5))

            Text("Complete a focus session to see your app usage")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xl)
    }

    // MARK: - Helpers

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1:
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 2:
            return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3:
            return Color(red: 0.80, green: 0.50, blue: 0.20) // Bronze
        default:
            return DesignTokens.Colors.accent
        }
    }
}

#Preview {
    ZStack {
        DesignTokens.Gradients.primaryBackground

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                // With data
                TopAppsCard(apps: [
                    AppUsageInfo(name: "Instagram", icon: "photo.on.rectangle", usageMinutes: 142, category: "Social"),
                    AppUsageInfo(name: "TikTok", icon: "play.rectangle.fill", usageMinutes: 98, category: "Entertainment"),
                    AppUsageInfo(name: "Twitter", icon: "bubble.left.and.bubble.right", usageMinutes: 76, category: "Social"),
                    AppUsageInfo(name: "YouTube", icon: "play.rectangle", usageMinutes: 65, category: "Entertainment"),
                    AppUsageInfo(name: "Safari", icon: "safari", usageMinutes: 54, category: "Productivity")
                ])

                // Empty state
                TopAppsCard(apps: [])
            }
            .padding()
        }
    }
}
