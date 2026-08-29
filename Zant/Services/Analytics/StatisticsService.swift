import SwiftUI

final class StatisticsService: StatisticsServiceProtocol, @unchecked Sendable {

    static let shared = StatisticsService()

    private init() {}

    func generateInsights(
        todaySessions: [FocusSessionRecord],
        yesterdaySessions: [FocusSessionRecord],
        streakDays: Int,
        focusScore: Int
    ) -> [InsightCard] {
        var insights: [InsightCard] = []

        // 1. Time comparison vs yesterday
        let todayMinutes = totalMinutes(from: todaySessions)
        let yesterdayMinutes = totalMinutes(from: yesterdaySessions)

        if todaySessions.isEmpty && yesterdaySessions.isEmpty {
            insights.append(InsightCard(
                icon: "play.circle.fill",
                title: "Start your first session",
                subtitle: "Begin focusing to see insights",
                color: DesignTokens.Colors.accent,
                metric: "0m"
            ))
        } else if todayMinutes > yesterdayMinutes {
            let diff = todayMinutes - yesterdayMinutes
            insights.append(InsightCard(
                icon: "arrow.up.right",
                title: "\(diff)m more than yesterday",
                subtitle: "Great improvement today",
                color: DesignTokens.Colors.success,
                metric: "+\(diff)m"
            ))
        } else if yesterdayMinutes > todayMinutes {
            let diff = yesterdayMinutes - todayMinutes
            insights.append(InsightCard(
                icon: "arrow.down.right",
                title: "You saved \(diff)m today",
                subtitle: "Less screen time than yesterday",
                color: DesignTokens.Colors.success,
                metric: "\(diff)m"
            ))
        } else {
            insights.append(InsightCard(
                icon: "equal.circle.fill",
                title: "Same as yesterday",
                subtitle: "Keep your focus consistent",
                color: DesignTokens.Colors.accent,
                metric: "\(todayMinutes)m"
            ))
        }

        // 2. Score trend
        if focusScore >= 80 {
            insights.append(InsightCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Focus score is great",
                subtitle: "You're in the zone today",
                color: DesignTokens.Colors.accent,
                metric: "\(focusScore)%"
            ))
        } else if focusScore >= 50 {
            insights.append(InsightCard(
                icon: "chart.line.flattrend.xyaxis",
                title: "Score is improving",
                subtitle: "Keep going to reach 80+",
                color: DesignTokens.Colors.warning,
                metric: "\(focusScore)%"
            ))
        } else {
            insights.append(InsightCard(
                icon: "chart.line.downtrend.xyaxis",
                title: "Room to improve",
                subtitle: "Start a session to boost your score",
                color: DesignTokens.Colors.warning,
                metric: "\(focusScore)%"
            ))
        }

        // 3. Top activity or streak
        if let topTag = topSessionTag(from: todaySessions) {
            let tagMinutes = minutesForTag(topTag, in: todaySessions)
            insights.append(InsightCard(
                icon: "exclamationmark.triangle.fill",
                title: "Top: \(topTag.rawValue)",
                subtitle: "\(tagMinutes) min focused today",
                color: DesignTokens.Colors.warning,
                metric: "\(tagMinutes)m"
            ))
        } else if streakDays > 0 {
            insights.append(InsightCard(
                icon: "flame.fill",
                title: "\(streakDays) day streak",
                subtitle: "Keep it going tomorrow",
                color: .orange,
                metric: "\(streakDays)d"
            ))
        } else {
            insights.append(InsightCard(
                icon: "flame",
                title: "Start your streak",
                subtitle: "Complete a session to begin",
                color: .orange,
                metric: "0d"
            ))
        }

        return insights
    }

    // MARK: - Private

    private func totalMinutes(from sessions: [FocusSessionRecord]) -> Int {
        sessions.reduce(0) { $0 + $1.actualDuration } / 60
    }

    private func topSessionTag(from sessions: [FocusSessionRecord]) -> SessionTag? {
        let tagCounts = Dictionary(grouping: sessions.compactMap(\.tag), by: { $0 })
        return tagCounts.max(by: { $0.value.count < $1.value.count })?.key
    }

    private func minutesForTag(_ tag: SessionTag, in sessions: [FocusSessionRecord]) -> Int {
        sessions
            .filter { $0.tag == tag }
            .reduce(0) { $0 + $1.actualDuration } / 60
    }
}
