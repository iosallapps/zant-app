import Foundation

/// Manages streak tracking with timezone-aware midnight boundaries.
@MainActor
final class StreakService: StreakServiceProtocol {

    static let shared = StreakService()

    private let defaults = UserDefaultsManager.shared

    private init() {}

    func checkAndUpdateStreak() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        guard let lastActive = defaults.lastActiveDate else {
            // First ever session
            defaults.lastActiveDate = today
            defaults.currentStreakLength = 1
            return
        }

        let lastActiveDay = calendar.startOfDay(for: lastActive)
        let daysDifference = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0

        switch daysDifference {
        case 0:
            // Same day — streak already counted
            break
        case 1:
            // Consecutive day — increment streak
            defaults.currentStreakLength += 1
            defaults.lastActiveDate = today
        default:
            // Missed day(s) — reset streak
            defaults.currentStreakLength = 1
            defaults.lastActiveDate = today
        }
    }

    func currentStreakLength() -> Int {
        defaults.currentStreakLength
    }

    func useFreeze() async -> Bool {
        guard defaults.streakFreezeCount > 0 else { return false }
        defaults.streakFreezeCount -= 1
        // Mark today as active to preserve streak
        defaults.lastActiveDate = Calendar.current.startOfDay(for: .now)
        return true
    }
}
