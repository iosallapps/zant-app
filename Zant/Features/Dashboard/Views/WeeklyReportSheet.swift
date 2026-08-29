import SwiftUI

/// Displays a summary of this week's focus stats.
struct WeeklyReportSheet: View {

    @Environment(\.dismiss) private var dismiss

    let totalFocusMinutes: Int
    let sessionsCompleted: Int
    let currentStreak: Int
    let focusScore: Int

    var body: some View {
        NavigationStack {
            ZStack {
                ZantMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.xxl) {
                        headerIcon
                        statsGrid
                        focusScoreRow
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.top, DesignTokens.Spacing.xl)
                    .padding(.bottom, DesignTokens.Spacing.huge)
                }
            }
            .navigationTitle(Strings.Dashboard.weeklyReportTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.General.done) { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Header

    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(DesignTokens.Colors.accent.opacity(0.15))
                .frame(width: 80, height: 80)

            Image(systemName: "chart.bar.fill")
                .font(.system(size: DesignTokens.IconSize.xxl, weight: .medium))
                .foregroundStyle(DesignTokens.Colors.accent)
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
            ],
            spacing: DesignTokens.Spacing.md
        ) {
            statCard(
                icon: "timer",
                value: formatMinutes(totalFocusMinutes),
                label: Strings.Dashboard.totalFocusMinutes,
                color: DesignTokens.Colors.accent
            )
            statCard(
                icon: "checkmark.circle.fill",
                value: "\(sessionsCompleted)",
                label: Strings.Dashboard.sessionsCompleted,
                color: DesignTokens.Colors.success
            )
            statCard(
                icon: "flame.fill",
                value: "\(currentStreak)",
                label: Strings.Dashboard.currentStreak,
                color: .orange
            )
            statCard(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(focusScore)%",
                label: Strings.Dashboard.focusScoreTrend,
                color: scoreColor
            )
        }
    }

    // MARK: - Focus Score Row

    private var focusScoreRow: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Circle()
                .fill(scoreColor.opacity(0.15))
                .frame(width: 10, height: 10)

            Text(Strings.Dashboard.focusScoreLabel(focusScore))
                .font(DesignTokens.Typography.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
    }

    // MARK: - Stat Card

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: DesignTokens.IconSize.md, weight: .semibold))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(DesignTokens.Typography.title2)
                .foregroundStyle(.white)

            Text(label)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(Color.white.opacity(0.04))
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
    }

    // MARK: - Helpers

    private var scoreColor: Color {
        if focusScore >= 80 { return DesignTokens.Colors.scoreGreen }
        if focusScore >= 50 { return DesignTokens.Colors.scoreYellow }
        return DesignTokens.Colors.scoreRed
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

#Preview {
    WeeklyReportSheet(
        totalFocusMinutes: 340,
        sessionsCompleted: 12,
        currentStreak: 5,
        focusScore: 72
    )
}
