import SwiftUI
import SwiftData
import Charts

// MARK: - Stats View

struct StatsView: View {

    @Environment(AppState.self) private var appState
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @State private var stats: EnhancedSessionStatsDTO?
    @State private var weeklyStats: WeeklyStatsDTO?
    @State private var isLoading = true
    @State private var selectedMonth = Date()

    var body: some View {
        ZStack {
            AmbientBackground()

            if router.selectedTab == .rewards {
                ParticleCanvasView()
                    .opacity(0.2)
                    .ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.xl) {
                    // Header
                    headerSection
                        .staggeredAppear(index: 0)

                    if let stats {
                        // Key metrics cards
                        keyMetricsSection(stats)
                            .staggeredAppear(index: 1)

                        // Weekly chart
                        if let weeklyStats {
                            weeklyChartSection(weeklyStats)
                                .staggeredAppear(index: 2)
                        }

                        // Calendar view
                        calendarSection(stats)
                            .staggeredAppear(index: 3)

                        // Recent sessions
                        recentSessionsSection(stats)
                            .staggeredAppear(index: 4)

                        // Tag breakdown
                        tagBreakdownSection(stats)
                            .staggeredAppear(index: 5)
                    } else if isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 100)
                    }

                    Spacer(minLength: DesignTokens.Spacing.huge)
                }
                .padding(.horizontal, DesignTokens.Spacing.xl)
                .padding(.top, DesignTokens.Spacing.lg)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await loadStats()
        }
        .refreshable {
            await loadStats()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Statistics")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Spacer()
        }
    }

    // MARK: - Key Metrics

    private func keyMetricsSection(_ stats: EnhancedSessionStatsDTO) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricCard(
                icon: "flame.fill",
                color: .orange,
                value: "\(stats.currentStreak)",
                label: "Day Streak",
                subtitle: "Longest: \(stats.longestStreak)"
            )

            metricCard(
                icon: "chart.bar.fill",
                color: DesignTokens.Colors.accent,
                value: "\(stats.totalSessions)",
                label: "Total Sessions",
                subtitle: "All time"
            )

            metricCard(
                icon: "clock.fill",
                color: DesignTokens.Colors.accentTeal,
                value: String(format: "%.1f", stats.totalHours),
                label: "Total Hours",
                subtitle: "Focused time"
            )

            metricCard(
                icon: "calendar.badge.clock",
                color: DesignTokens.Colors.success,
                value: "\(stats.averageSessionDuration)",
                label: "Avg Duration",
                subtitle: "Minutes per session"
            )
        }
    }

    private func metricCard(
        icon: String,
        color: Color,
        value: String,
        label: String,
        subtitle: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }

            Spacer()

            // Value
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)

            // Label
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Weekly Chart

    private func weeklyChartSection(_ weeklyStats: WeeklyStatsDTO) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Last 7 Days")

            VStack(spacing: DesignTokens.Spacing.sm) {
                // Chart
                Chart {
                    ForEach(Array(weeklyStats.days.enumerated()), id: \.offset) { index, day in
                        BarMark(
                            x: .value("Day", weekdayAbbreviation(for: day)),
                            y: .value("Minutes", weeklyStats.minutes[index])
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                // Summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(weeklyStats.sessions.reduce(0, +)) sessions")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("This week")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(weeklyStats.minutes.reduce(0, +)) min")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("Total time")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.top, DesignTokens.Spacing.sm)
            }
            .padding(DesignTokens.Spacing.lg)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }

    // MARK: - Calendar Section

    private func calendarSection(_ stats: EnhancedSessionStatsDTO) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Focus Calendar")

            StreakCalendarView(
                activeDays: stats.activeDays,
                currentStreak: stats.currentStreak,
                month: selectedMonth
            )
        }
    }

    // MARK: - Recent Sessions

    private func recentSessionsSection(_ stats: EnhancedSessionStatsDTO) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Recent Sessions")

            if stats.recentSessions.isEmpty {
                emptyState(
                    icon: "timer",
                    message: "No sessions yet. Start your first focus session!"
                )
            } else {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(stats.recentSessions.prefix(5), id: \.id) { session in
                        sessionRow(session)
                    }
                }
            }
        }
    }

    private func sessionRow(_ session: FocusSession) -> some View {
        HStack(spacing: 12) {
            // Tag indicator
            if let tag = SessionTag(rawValue: session.tag) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: tag.gradient.map { Color(hex: $0) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(tag.rawValue.prefix(1)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }

            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.tag.capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Text(timeAgoString(from: session.endDate))
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Duration
            Text("\(session.durationMinutes) min")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    // MARK: - Tag Breakdown

    private func tagBreakdownSection(_ stats: EnhancedSessionStatsDTO) -> some View{
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Session Types")

            if stats.sessionsByTag.isEmpty {
                emptyState(
                    icon: "tag",
                    message: "Session types will appear here"
                )
            } else {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(stats.sessionsByTag.sorted(by: { $0.value > $1.value }), id: \.key) { tag, count in
                        tagRow(tag: tag, count: count, total: stats.totalSessions)
                    }
                }
            }
        }
    }

    private func tagRow(tag: SessionTag, count: Int, total: Int) -> some View {
        let percentage = total > 0 ? Double(count) / Double(total) : 0.0

        return HStack(spacing: 12) {
            // Tag circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: tag.gradient.map { Color(hex: $0) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)

            // Label
            Text(tag.rawValue.capitalized)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            // Count and percentage
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Text(String(format: "%.0f%%", percentage * 100))
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    // MARK: - Empty State

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.3))

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xxl)
    }

    // MARK: - Helper Methods

    private func loadStats() async {
        isLoading = true

        do {
            let statsService = StatsService(modelContext: modelContext)
            self.stats = try await statsService.getSessionStats()
            self.weeklyStats = try await statsService.getWeeklyStats()
        } catch {
            print("Error loading stats: \(error)")
        }

        isLoading = false
    }

    private func weekdayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let difference = now.timeIntervalSince(date)

        let hours = Int(difference / 3600)
        let days = Int(difference / 86400)

        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StatsView()
    }
    .environment(AppState())
    .environment(NavigationRouter())
    .modelContainer(for: FocusSession.self, inMemory: true)
}
