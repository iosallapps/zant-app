import Foundation

// swiftlint:disable file_length

/// Centralized user-facing strings. Every Text, Label, Button title, navigationTitle,
/// alert, and sheet title should reference a constant here.
enum Strings {

    // MARK: - General

    enum General {
        static let appName = AppConstants.appName
        static let continueButton = "Continue"
        static let cancel = "Cancel"
        static let done = "Done"
        static let soon = "Soon"
        static let pro = "PRO"
        static let free = "Free"
        static let premium = "Premium"
        static let upgrade = "Upgrade"
        static let minutes = "minutes"
        static let remaining = "remaining"
        static let breakLabel = "Break"
        static let resume = "Resume"
        static let getStarted = "Get Started"
        static let skipForNow = "Skip for now"
        static let focusApp = "Focus App"
    }

    // MARK: - Dashboard

    enum Dashboard {
        static let stayFocused = "Stay focused today"
        static let focus = "FOCUS"
        static let screenTime = "SCREEN TIME"
        static let sessions = "SESSIONS"
        static let dailyInsightsTitle = "Daily Insights"
        static let dailyInsightsSubtitle = "Today's update on your focus"
        static let quickActions = "Quick Actions"
        static let startSession = "Start Session"
        static let blockApps = "Block Apps"
        static let weeklyReport = "Weekly Report"
        static let dailyChallenge = "Daily Challenge"
        static let activeBlocks = "Active Blocks"
        static let appsBlocked = "Apps Blocked"
        static let appsBlockedSubtitle = "Selected apps are currently shielded"
        static let noActiveBlocks = "No active blocks"
        static let noActiveBlocksSubtitle = "Start a session or block distracting apps"

        // Score messages
        static let scoreGreat = "Great focus today! Keep it up."
        static let scoreOnTrack = "You're on track. Stay focused."
        static let scoreImprove = "Let's improve your focus today."

        // Weekly Report Sheet
        static let weeklyReportTitle = "Weekly Report"
        static let totalFocusMinutes = "Total Focus Minutes"
        static let sessionsCompleted = "Sessions Completed"
        static let currentStreak = "Current Streak"
        static let focusScoreTrend = "Focus Score Trend"
        static let days = "days"
        static let noDataYet = "Complete sessions to see your weekly report."

        static func focusScoreLabel(_ score: Int) -> String {
            if score >= 80 { return "Excellent" }
            if score >= 50 { return "Good" }
            return "Needs improvement"
        }
    }

    // MARK: - Focus Sessions

    enum FocusSessions {
        static let focusSession = "Focus Session"
        static let duration = "Duration"
        static let mode = "Mode"
        static let tag = "Tag"
        static let startSessionButton = "Start Session"
        static let stopSession = "Stop Session"
        static let takeBreak = "Take a Break"
        static let resumeSession = "Resume Session"
        static let endSessionTitle = "End Session?"
        static let endSessionMessage = "Your progress will be saved but the session will end early."
        static let takeBreakTitle = "Take a Break"
        static let oneMinute = "1 minute"
        static let fiveMinutes = "5 minutes"
        static let fifteenMinutes = "15 minutes"
        static let cancelAnytime = "Cancel anytime"
        static let appsBlockedMode = "Apps blocked"
        static let cantQuit = "Can't quit"
    }

    // MARK: - Rewards

    enum Rewards {
        static let rewards = "Rewards"
        static let levelPrefix = "Level"
        static let dayStreak = "day streak"
        static let gemCollection = "Cup Collection"
        static let dailyChallenges = "Daily Challenges"

        static func nextMilestone(_ days: Int) -> String {
            "Next: \(days) days"
        }

        static func xpProgress(_ current: Int, _ total: Int) -> String {
            "\(current)/\(total) XP"
        }

        static func xpReward(_ amount: Int) -> String {
            "+\(amount) XP"
        }
    }

    // MARK: - Profile

    enum Profile {
        static let totalSessions = "Total Sessions"
        static let focusTime = "Focus Time"
        static let bestStreak = "Best Streak"
        static let days = "days"
        static let collection = "Collection"
        static let viewAll = "View All →"
        static let completeSessionsForGems = "Complete sessions to earn cups"
        static let general = "GENERAL"
        static let dailyTarget = "Daily Target"
        static let notifications = "Notifications"
        static let on = "On"
        static let off = "Off"
        static let blocking = "BLOCKING"
        static let defaultStrictness = "Default Strictness"
        static let interventionDuration = "Intervention Duration"
        static let subscription = "SUBSCRIPTION"
        static let currentPlan = "Current Plan"
        static let restorePurchases = "Restore Purchases"
        static let purchasesRestored = "Purchases restored"
        static let restoreFailed = "Restore failed"
        static let about = "ABOUT"
        static let version = "Version"
        static let versionNumber = "1.0.0"
        static let privacyPolicy = "Privacy Policy"
        static let termsOfService = "Terms of Service"
        static let rateApp = "Rate App"
        static let dangerZone = "DANGER ZONE"
        static let deleteAllData = "Delete All Data"
        static let deleteConfirmTitle = "Delete All Data?"
        static let deleteConfirmMessage = "This will permanently delete all your sessions, cups, and progress. This cannot be undone."
        static let deleteEverything = "Delete Everything"
        static let finalDeleteTitle = "Are you absolutely sure?"
        static let finalDeleteMessage = "This action is irreversible. All sessions, cups, levels, and progress will be permanently erased."
        static let yesDeleteEverything = "Yes, Delete Everything"
        static let dailyTargetTitle = "Daily Target"
        static let defaultStrictnessTitle = "Default Strictness"
        static let interventionDurationTitle = "Intervention Duration"

        static func interventionSeconds(_ seconds: Int) -> String {
            "\(seconds) seconds"
        }

        static func interventionValue(_ seconds: Int) -> String {
            "\(seconds)s"
        }

        static func memberSince(_ dateString: String) -> String {
            "Member since \(dateString)"
        }
    }

    // MARK: - Onboarding

    enum Onboarding {
        // Start
        static let takeBackYourTime = "Take back your time."
        static let allInOneCompanion = "Your all-in-one digital wellness companion"
        static let blockApps = "Block\nApps"
        static let focusSessions = "Focus\nSessions"
        static let trackProgress = "Track\nProgress"
        static let earnRewards = "Earn\nRewards"

        // Time Screen
        static let timeScreenTitle = "How much time do you spend\non your phone each day?"
        static let hoursPerDay = "hours per day"
        static let zeroHours = "0h"
        static let tenPlusHours = "10h+"

        // Habit Screen
        static let habitScreenTitle = "What habits would you\nlike to change?"
        static let selectAllThatApply = "Select all that apply"
        static let describeHabitPlaceholder = "Describe your habit..."

        // Calculate Time
        static let screenTimeReality = "Your screen time reality"
        static let spentEveryDay = "spent on your phone every day"
        static let lifeLostEveryYear = "of your life lost every year"
        static let youCouldInstead = "You could instead..."
        static let hrs = " hrs"
        static let days = " days"
        static let takeBackMyTime = "Take Back My Time"

        // Paywall
        static let unlockPotential = "Unlock Your\nFull Potential"
        static let unbreakableFocusMode = "Unbreakable Focus Mode"
        static let smartInterventions = "Smart Interventions"
        static let fullAnalytics = "Full Analytics & Insights"
        static let allGemTypes = "All 7 Cup Types"
        static let yearly = "Yearly"
        static let monthly = "Monthly"
        static let save50 = "Save 50%"
        static let startFreeTrial = "Start Free Trial"
        static let subscribe = "Subscribe"
        static let continueWithFree = "Continue with Free"
        static let purchaseFailed = "Purchase failed. Please try again."

        static func freeTrialText(_ days: Int) -> String {
            "\(days)-day free trial"
        }

        // Screen Time Connect
        static let connectScreenTime = "Connect Screen Time"
        static let screenTimeDescription = "Zant needs Screen Time access to block\ndistracting apps and track your progress"
        static let blockAppsBullet = "Block apps during focus sessions"
        static let monitorScreenTime = "Monitor your daily screen time"
        static let setSmartLimits = "Set smart limits on distracting apps"
        static let dataPrivacy = "Your data never leaves your device."
        static let permissionDenied = "Permission denied. You can enable this later in Settings."

        // Cup Cracking
        static let tapToReveal = "Tap to reveal your reward"
        static let welcomeCup = "Welcome Cup"
        static let journeyStarts = "Your journey to focus starts now"
        static let continueToZant = "Continue to Zant"

        // Personalized alternatives (defaults)
        static let readBooks = "Read 50+ books per year"
        static let buildFitness = "Build a consistent fitness routine"
        static let learnSkill = "Learn a new skill or language"
    }

    // MARK: - Blocking

    enum Blocking {
        static let selectApps = "Select Apps"
        static let chooseAppsToBlock = "Choose apps to block during focus sessions"
        static let saveSelection = "Save Selection"
        static let saveAndBlockNow = "Save & Block Now"
        static let newSchedule = "New Schedule"
        static let createSchedule = "Create Schedule"
        static let name = "Name"
        static let namePlaceholder = "e.g. Work Focus"
        static let time = "Time"
        static let start = "Start"
        static let end = "End"
        static let daysLabel = "Days"
        static let strictness = "Strictness"
        static let appPickerSimulatorMessage = "App picker requires a physical device"
        static let selectAtLeastOneDay = "Select at least one day"
        static let endTimeAfterStart = "End time must be after start time"
        static let blockScheduleDefault = "Block Schedule"
        static let appSelectionSaved = "App selection saved"
        static let selectAppsFirst = "Select apps to block first"
        static let failedToApplyBlocks = "Failed to apply blocks — no apps selected"

        static func appsSelected(_ count: Int) -> String {
            "\(count) apps & categories selected"
        }
    }

    // MARK: - Floating Session Bar

    enum FloatingBar {
        static let breakLabel = "Break"
        static let resumeLabel = "Resume"
    }

    // MARK: - URLs

    enum URLs {
        static let privacyPolicy = "https://zant.app/privacy"
        static let termsOfService = "https://zant.app/terms"
    }
}

// swiftlint:enable file_length
