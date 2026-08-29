import Foundation

// MARK: - Screen Time

protocol ScreenTimeServiceProtocol: Sendable {
    func requestAuthorization() async throws
    func checkAuthorizationStatus()
    var isAuthorized: Bool { get }
}

// MARK: - App Blocking

protocol AppBlockingServiceProtocol: Sendable {
    /// Returns false if no app selection exists (caller should show error).
    @discardableResult
    func applyBlocks(strictness: BlockingStrictness) async -> Bool
    func removeBlocks() async
    func isCurrentlyBlocking() -> Bool
    func hasAppSelection() -> Bool
}

// MARK: - Gem

protocol GemServiceProtocol: Sendable {
    func earnGem(type: GemType, reason: GemReason) async
    func getAllGems() async -> [Gem]
    func gemCount(for type: GemType) async -> Int
}

// MARK: - Crystal

protocol CrystalServiceProtocol: Sendable {
    func earnCrystal(type: CrystalType, reason: CrystalReason) async
    func getAllCrystals() async -> [Crystal]
    func crystalCount(for type: CrystalType) async -> Int
}

// MARK: - Streak

protocol StreakServiceProtocol: Sendable {
    func checkAndUpdateStreak() async
    func currentStreakLength() -> Int
    func useFreeze() async -> Bool
}

// MARK: - Challenge

protocol ChallengeServiceProtocol: Sendable {
    func generateDailyChallenges() async -> [Challenge]
    func updateProgress(for challengeID: UUID, value: Double) async
    func completedChallenges() async -> [Challenge]
}

// MARK: - Notification

protocol NotificationServiceProtocol: Sendable {
    func requestPermission() async -> Bool
    func scheduleSessionReminder(at hour: Int, minute: Int) async
    func scheduleStreakWarning() async
    func cancelAll() async
}

// MARK: - StoreKit

protocol StoreKitServiceProtocol: Sendable {
    func loadProducts() async
    func purchase(productID: String) async throws -> Bool
    func restorePurchases() async throws
    var isPremium: Bool { get }
}

// MARK: - Session Repository

protocol SessionRepositoryProtocol: Sendable {
    func save(session: FocusSessionRecord) async throws
    func fetchToday() async throws -> [FocusSessionRecord]
    func fetchYesterday() async throws -> [FocusSessionRecord]
    func fetchSessions(for date: Date) async throws -> [FocusSessionRecord]
    func fetchAll() async throws -> [FocusSessionRecord]
    func totalCompletedSessions() async throws -> Int
    func totalFocusMinutes() async throws -> Int
}

// MARK: - Focus Score

protocol FocusScoreServiceProtocol: Sendable {
    func calculateScore(focusMinutes: Double, targetMinutes: Int, sessionsCompleted: Int, streakDays: Int) -> Int
}

// MARK: - Statistics

protocol StatisticsServiceProtocol: Sendable {
    func generateInsights(todaySessions: [FocusSessionRecord], yesterdaySessions: [FocusSessionRecord], streakDays: Int, focusScore: Int) -> [InsightCard]
}

// MARK: - Level

protocol LevelServiceProtocol: Sendable {
    func awardXP(_ amount: Int) -> (newXP: Int, newLevel: Int, didLevelUp: Bool)
    func currentLevel() -> Int
    func currentXP() -> Int
    func xpForCurrentLevel() -> Int
    func xpForNextLevel() -> Int
    func xpProgressInLevel() -> Int
    func xpNeededForLevel() -> Int
}

// MARK: - Stats Repository

protocol StatsRepositoryProtocol: Sendable {
    func saveDaily(stats: DailyStatsRecord) async throws
    func fetchStats(for date: Date) async throws -> DailyStatsRecord?
    func fetchStats(from: Date, to: Date) async throws -> [DailyStatsRecord]
}

// MARK: - Blocking Rule Repository

protocol BlockingRuleRepositoryProtocol: Sendable {
    func save(rule: BlockingRuleRecord) async throws
    func fetchAll() async throws -> [BlockingRuleRecord]
    func fetchActive() async throws -> [BlockingRuleRecord]
    func delete(ruleID: UUID) async throws
    func update(rule: BlockingRuleRecord) async throws
}
