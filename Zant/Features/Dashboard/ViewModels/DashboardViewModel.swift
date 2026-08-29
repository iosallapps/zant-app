import SwiftUI

@Observable
@MainActor
final class DashboardViewModel {

    // MARK: - State

    var focusScore: Int = 0
    var streakDays: Int = 0
    var focusMinutesToday: Int = 0
    var sessionsToday: Int = 0
    var insights: [InsightCard] = []
    var isCurrentlyBlocking: Bool = false
    var isLoading: Bool = false
    var earnedCrystals: [CrystalType] = []

    // Weekly report
    var weeklyFocusMinutes: Int = 0
    var weeklySessionsCompleted: Int = 0

    // MARK: - Computed

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    var scoreColor: Color {
        if focusScore >= 80 { return DesignTokens.Colors.scoreGreen }
        if focusScore >= 50 { return DesignTokens.Colors.scoreYellow }
        return DesignTokens.Colors.scoreRed
    }

    var scoreMessage: String {
        if focusScore >= 80 { return Strings.Dashboard.scoreGreat }
        if focusScore >= 50 { return Strings.Dashboard.scoreOnTrack }
        return Strings.Dashboard.scoreImprove
    }

    // MARK: - Dependencies

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Load

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        let todaySessions = (try? await appState.sessionRepository.fetchToday()) ?? []
        let yesterdaySessions = (try? await appState.sessionRepository.fetchYesterday()) ?? []

        sessionsToday = todaySessions.filter(\.wasCompleted).count
        focusMinutesToday = todaySessions.reduce(0) { $0 + $1.actualDuration } / 60
        streakDays = appState.streakService.currentStreakLength()

        let targetMinutes = Int(UserDefaultsManager.shared.dailyScreenTimeTarget * 60)
        focusScore = appState.focusScoreService.calculateScore(
            focusMinutes: Double(focusMinutesToday),
            targetMinutes: targetMinutes,
            sessionsCompleted: sessionsToday,
            streakDays: streakDays
        )

        insights = appState.statisticsService.generateInsights(
            todaySessions: todaySessions,
            yesterdaySessions: yesterdaySessions,
            streakDays: streakDays,
            focusScore: focusScore
        )

        isCurrentlyBlocking = appState.appBlockingService.isCurrentlyBlocking()

        // Load earned crystals for cup widget
        earnedCrystals = await appState.crystalService.getAllCrystals().map { $0.type }
    }

    /// Loads focus data for the current week (Mon-Sun).
    func loadWeeklyData() async {
        let calendar = Calendar.current
        let today = Date()

        // Walk back up to 6 days to cover the current week
        var totalMinutes = 0
        var totalSessions = 0
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let sessions = (try? await appState.sessionRepository.fetchSessions(for: date)) ?? []
            totalMinutes += sessions.reduce(0) { $0 + $1.actualDuration } / 60
            totalSessions += sessions.filter(\.wasCompleted).count
        }
        weeklyFocusMinutes = totalMinutes
        weeklySessionsCompleted = totalSessions
    }

    // MARK: - Helpers

    func formatTime(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}
