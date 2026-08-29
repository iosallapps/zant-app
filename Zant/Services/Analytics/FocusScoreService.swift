import Foundation

final class FocusScoreService: FocusScoreServiceProtocol, @unchecked Sendable {

    static let shared = FocusScoreService()

    private init() {}

    func calculateScore(focusMinutes: Double, targetMinutes: Int, sessionsCompleted: Int, streakDays: Int) -> Int {
        let target = max(Double(targetMinutes), 1.0)

        // 40%: ratio of focus time vs daily target
        let timeRatio = min(focusMinutes / target, 1.0)

        // 30%: completed enough sessions
        let sessionRatio = min(Double(sessionsCompleted) / Double(AppConstants.dailySessionTarget), 1.0)

        // 30%: consistency bonus (streak, target: 7 days)
        let streakRatio = min(Double(streakDays) / 7.0, 1.0)

        let rawScore = (timeRatio * 0.4 + sessionRatio * 0.3 + streakRatio * 0.3) * 100
        return Int(min(max(rawScore, 0), 100))
    }
}
