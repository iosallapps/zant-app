import SwiftUI
import SwiftData

@Observable
@MainActor
final class AppState {

    // MARK: - Onboarding
    // Stored properties so @Observable can track mutations and trigger SwiftUI updates.
    // Each didSet syncs back to UserDefaults for persistence.

    var isOnboarded: Bool {
        didSet { UserDefaultsManager.shared.isOnboarded = isOnboarded }
    }

    var onboardingStep: Int {
        didSet { UserDefaultsManager.shared.onboardingStep = onboardingStep }
    }

    // MARK: - Permissions

    var hasScreenTimePermission: Bool {
        didSet { UserDefaultsManager.shared.hasScreenTimePermission = hasScreenTimePermission }
    }

    var hasNotificationPermission: Bool = false

    // MARK: - Premium

    var isPremium: Bool {
        didSet { UserDefaultsManager.shared.isPremium = isPremium }
    }

    // MARK: - Active Session

    var activeSessionStartedAt: Date? {
        didSet { UserDefaultsManager.shared.activeSessionStartedAt = activeSessionStartedAt }
    }

    var activeSessionTargetDuration: Int {
        didSet { UserDefaultsManager.shared.activeSessionTargetDuration = activeSessionTargetDuration }
    }

    var activeSessionMode: String? {
        didSet { UserDefaultsManager.shared.activeSessionMode = activeSessionMode }
    }

    var activeSessionTag: String? {
        didSet { UserDefaultsManager.shared.activeSessionTag = activeSessionTag }
    }

    var isOnBreak: Bool = false

    // MARK: - Services

    let screenTimeService: any ScreenTimeServiceProtocol
    let gemService: any GemServiceProtocol
    let crystalService: any CrystalServiceProtocol
    let streakService: any StreakServiceProtocol
    let challengeService: any ChallengeServiceProtocol
    let notificationService: any NotificationServiceProtocol
    let storeKitService: any StoreKitServiceProtocol
    let focusScoreService: any FocusScoreServiceProtocol
    let statisticsService: any StatisticsServiceProtocol
    let levelService: any LevelServiceProtocol
    let appBlockingService: any AppBlockingServiceProtocol
    var timerService: TimerService?

    // MARK: - Repositories

    let sessionRepository: any SessionRepositoryProtocol
    let statsRepository: any StatsRepositoryProtocol
    let blockingRuleRepository: any BlockingRuleRepositoryProtocol

    // MARK: - Init

    init(
        screenTimeService: (any ScreenTimeServiceProtocol)? = nil,
        gemService: (any GemServiceProtocol)? = nil,
        crystalService: (any CrystalServiceProtocol)? = nil,
        streakService: (any StreakServiceProtocol)? = nil,
        challengeService: (any ChallengeServiceProtocol)? = nil,
        notificationService: (any NotificationServiceProtocol)? = nil,
        storeKitService: (any StoreKitServiceProtocol)? = nil,
        focusScoreService: (any FocusScoreServiceProtocol)? = nil,
        statisticsService: (any StatisticsServiceProtocol)? = nil,
        levelService: (any LevelServiceProtocol)? = nil,
        appBlockingService: (any AppBlockingServiceProtocol)? = nil,
        sessionRepository: (any SessionRepositoryProtocol)? = nil,
        statsRepository: (any StatsRepositoryProtocol)? = nil,
        blockingRuleRepository: (any BlockingRuleRepositoryProtocol)? = nil
    ) {
        let defaults = UserDefaultsManager.shared
        self.isOnboarded = defaults.isOnboarded
        self.onboardingStep = defaults.onboardingStep
        self.hasScreenTimePermission = defaults.hasScreenTimePermission
        self.isPremium = defaults.isPremium
        self.activeSessionStartedAt = defaults.activeSessionStartedAt
        self.activeSessionTargetDuration = defaults.activeSessionTargetDuration
        self.activeSessionMode = defaults.activeSessionMode
        self.activeSessionTag = defaults.activeSessionTag
        self.screenTimeService = screenTimeService ?? ScreenTimeService.shared
        self.gemService = gemService ?? GemService.shared
        self.crystalService = crystalService ?? CrystalService.shared
        self.streakService = streakService ?? StreakService.shared
        self.challengeService = challengeService ?? ChallengeService.shared
        self.notificationService = notificationService ?? NotificationService.shared
        self.storeKitService = storeKitService ?? StoreKitService.shared
        self.focusScoreService = focusScoreService ?? FocusScoreService.shared
        self.statisticsService = statisticsService ?? StatisticsService.shared
        self.levelService = levelService ?? LevelService.shared
        self.appBlockingService = appBlockingService ?? AppBlockingService.shared
        self.sessionRepository = sessionRepository ?? SessionRepository.shared
        self.statsRepository = statsRepository ?? StatsRepository.shared
        self.blockingRuleRepository = blockingRuleRepository ?? BlockingRuleRepository.shared
    }

    // MARK: - Expired Session Recovery

    /// Checks if a persisted session has already expired (e.g. after an app kill)
    /// and auto-completes it so the user isn't stuck in limbo.
    func checkForExpiredSession() async {
        // Use new TimerService if available
        if let timerService = timerService {
            await timerService.checkForExpiredSession()

            // Sync activeSessionStartedAt with SharedStorage
            if SharedStorage.shared.hasActiveSession {
                activeSessionStartedAt = SharedStorage.shared.sessionStartTime
            } else {
                activeSessionStartedAt = nil
            }
            return
        }

        // Fallback to legacy logic if TimerService not initialized
        guard let startedAt = activeSessionStartedAt else { return }
        guard activeSessionTargetDuration > 0 else { return }

        let deadline = startedAt.addingTimeInterval(TimeInterval(activeSessionTargetDuration * 60))
        guard Date() >= deadline else { return }

        let targetSeconds = activeSessionTargetDuration * 60

        let record = FocusSessionRecord(
            startedAt: startedAt,
            endedAt: deadline,
            targetDuration: targetSeconds,
            actualDuration: targetSeconds,
            mode: FocusMode(rawValue: activeSessionMode ?? "normal") ?? .normal,
            tag: activeSessionTag.flatMap { SessionTag(rawValue: $0) },
            wasCompleted: true
        )

        try? await sessionRepository.save(session: record)

        // Update quick-access stats
        let actualMinutes = targetSeconds / 60
        UserDefaultsManager.shared.totalSessionsCompleted += 1
        UserDefaultsManager.shared.totalFocusMinutes += actualMinutes

        // Remove any lingering app blocks
        await appBlockingService.removeBlocks()

        // Clear the stale session
        activeSessionStartedAt = nil
        activeSessionMode = nil
        activeSessionTag = nil
        activeSessionTargetDuration = 0
        isOnBreak = false
    }

    // MARK: - TimerService Setup

    /// Initialize TimerService with ModelContext
    func setupTimerService(modelContext: ModelContext) {
        self.timerService = TimerService(
            modelContext: modelContext,
            analyticsService: AnalyticsService.shared
        )
    }
}
