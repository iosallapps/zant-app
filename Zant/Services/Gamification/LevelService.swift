import Foundation

@MainActor
final class LevelService: LevelServiceProtocol {

    static let shared = LevelService()

    private let defaults = UserDefaultsManager.shared

    private init() {}

    func awardXP(_ amount: Int) -> (newXP: Int, newLevel: Int, didLevelUp: Bool) {
        let oldLevel = currentLevel()
        let newXP = defaults.currentXP + amount
        defaults.currentXP = newXP

        // Check for level-ups
        var level = oldLevel
        while newXP >= Level.xpRequired(for: level + 1) {
            level += 1
        }
        defaults.currentLevel = level

        return (newXP: newXP, newLevel: level, didLevelUp: level > oldLevel)
    }

    func currentLevel() -> Int {
        defaults.currentLevel
    }

    func currentXP() -> Int {
        defaults.currentXP
    }

    func xpForCurrentLevel() -> Int {
        Level.xpRequired(for: currentLevel())
    }

    func xpForNextLevel() -> Int {
        Level.xpRequired(for: currentLevel() + 1)
    }

    func xpProgressInLevel() -> Int {
        max(0, currentXP() - xpForCurrentLevel())
    }

    func xpNeededForLevel() -> Int {
        xpForNextLevel() - xpForCurrentLevel()
    }
}
