import Foundation

enum AppConstants {

    // MARK: - App Info

    static let appName = "zant"
    static let appGroupIdentifier = "group.iosallapps.Zant"
    static let bundleIdentifier = "iosallapps.Zant"

    // MARK: - Onboarding

    static let totalOnboardingSteps = 6
    static let maxSliderHours: Double = 10
    static let minHabitsRequired = 1
    static let gemCrackTapsRequired = 5

    // MARK: - Focus Sessions

    static let sessionPresets: [Int] = [15, 25, 30, 45, 60, 90, 120] // minutes
    static let minimumSessionMinutes = 15
    static let emergencyTapCount = 5

    // MARK: - Streaks

    static let streakMilestones: [Int] = [7, 14, 30, 60, 100, 365]
    static let freeStreakFreezesPerWeek = 0
    static let premiumStreakFreezesPerWeek = 1

    // MARK: - Gamification

    static let dailySessionTarget = 3
    static let maxLevel = 50
    static let freeDailyChallengeLimit = 3
    static let xpPerMinuteFocused = 2
    static let xpPerChallenge = 50
    static let xpPerGem = 25

    // MARK: - Blocking

    static let maxFreeSchedules = 1
    static let interventionBreathingDuration: TimeInterval = 12 // seconds
    static let reshieldTimeoutDuration: TimeInterval = 30 // seconds
    static let temporaryUnblockOptions: [Int] = [1, 5, 15] // minutes

    // MARK: - Focus Score Weights

    static let scoreWeightScreenTime: Double = 0.4
    static let scoreWeightStreak: Double = 0.2
    static let scoreWeightSessions: Double = 0.2
    static let scoreWeightLimits: Double = 0.2

    // MARK: - StoreKit

    static let monthlyProductID = "com.zant.pro.monthly"
    static let yearlyProductID = "com.zant.pro.yearly"
    static let monthlyPrice = "$4.99"
    static let yearlyPrice = "$29.99"
    static let freeTrialDays = 7

    // MARK: - Notifications

    static let defaultReminderHour = 9
    static let streakWarningHour = 21
    static let weeklyReportDay = 1 // Sunday
}
