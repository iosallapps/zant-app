import SwiftUI

@Observable
@MainActor
final class RewardsViewModel {

    // MARK: - State

    var currentLevel: Int = 1
    var currentXP: Int = 0
    var xpToNextLevel: Int = 100
    var xpProgress: Int = 0
    var streakDays: Int = 0
    var totalGems: Int = 0
    var crystalCollection: [(type: CrystalType, isEarned: Bool)] = []
    var challenges: [Challenge] = []
    var isLoading: Bool = false

    // MARK: - Computed

    var levelTitle: String {
        Level.title(for: currentLevel)
    }

    var nextMilestone: Int {
        let milestones = [7, 14, 30, 60, 100, 365]
        return milestones.first(where: { $0 > streakDays }) ?? 365
    }

    var xpProgressFraction: Double {
        guard xpToNextLevel > 0 else { return 0 }
        return Double(xpProgress) / Double(xpToNextLevel)
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
        currentLevel = appState.levelService.currentLevel()
        currentXP = appState.levelService.currentXP()
        xpProgress = appState.levelService.xpProgressInLevel()
        xpToNextLevel = appState.levelService.xpNeededForLevel()
        streakDays = appState.streakService.currentStreakLength()

        let earnedCrystals = await appState.crystalService.getAllCrystals()
        totalGems = earnedCrystals.count
        let earnedTypes = Set(earnedCrystals.map(\.type))
        crystalCollection = CrystalType.allCases.map { type in
            (type: type, isEarned: earnedTypes.contains(type))
        }

        challenges = await appState.challengeService.generateDailyChallenges()
    }
}
