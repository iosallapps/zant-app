import Foundation

/// Centralized UserDefaults access. Never use `UserDefaults.standard` directly.
final class UserDefaultsManager: Sendable {

    static let shared = UserDefaultsManager()

    private let defaults: UserDefaults
    private let sharedDefaults: UserDefaults

    private init() {
        self.defaults = UserDefaults.standard
        self.sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier) ?? .standard
    }

    // MARK: - Keys

    private enum Key {
        static let isOnboarded = "zant_isOnboarded"
        static let onboardingStep = "zant_onboardingStep"
        static let hasScreenTimePermission = "zant_hasScreenTimePermission"
        static let hasNotificationPermission = "zant_hasNotificationPermission"
        static let isPremium = "zant_isPremium"
        static let selectedTheme = "zant_selectedTheme"
        static let accentColor = "zant_accentColor"
        static let displayName = "zant_displayName"
        static let dailyScreenTimeTarget = "zant_dailyScreenTimeTarget"
        static let onboardingEstimate = "zant_onboardingEstimate"
        static let selectedHabits = "zant_selectedHabits"
        static let currentLevel = "zant_currentLevel"
        static let currentXP = "zant_currentXP"
        static let totalSessionsCompleted = "zant_totalSessionsCompleted"
        static let lastActiveDate = "zant_lastActiveDate"
        static let currentStreakLength = "zant_currentStreakLength"
        static let streakFreezeCount = "zant_streakFreezeCount"
        static let dailyReminderTime = "zant_dailyReminderTime"
        static let activeSessionStartedAt = "zant_activeSessionStartedAt"
        static let activeSessionTargetDuration = "zant_activeSessionTargetDuration"
        static let activeSessionMode = "zant_activeSessionMode"
        static let sliderInteracted = "zant_sliderInteracted"
        static let memberSinceDate = "zant_memberSinceDate"
        static let bestStreakLength = "zant_bestStreakLength"
        static let totalFocusMinutes = "zant_totalFocusMinutes"
        static let activeSessionTag = "zant_activeSessionTag"
        static let defaultBlockingStrictness = "zant_defaultBlockingStrictness"
        static let interventionDuration = "zant_interventionDuration"
    }

    // MARK: - Onboarding

    var isOnboarded: Bool {
        get { defaults.bool(forKey: Key.isOnboarded) }
        set { defaults.set(newValue, forKey: Key.isOnboarded) }
    }

    var onboardingStep: Int {
        get { defaults.integer(forKey: Key.onboardingStep) }
        set { defaults.set(newValue, forKey: Key.onboardingStep) }
    }

    var onboardingEstimate: Double {
        get { defaults.double(forKey: Key.onboardingEstimate) }
        set { defaults.set(newValue, forKey: Key.onboardingEstimate) }
    }

    var selectedHabits: [String] {
        get { defaults.stringArray(forKey: Key.selectedHabits) ?? [] }
        set { defaults.set(newValue, forKey: Key.selectedHabits) }
    }

    var sliderInteracted: Bool {
        get { defaults.bool(forKey: Key.sliderInteracted) }
        set { defaults.set(newValue, forKey: Key.sliderInteracted) }
    }

    // MARK: - Permissions

    var hasScreenTimePermission: Bool {
        get { defaults.bool(forKey: Key.hasScreenTimePermission) }
        set { defaults.set(newValue, forKey: Key.hasScreenTimePermission) }
    }

    var hasNotificationPermission: Bool {
        get { defaults.bool(forKey: Key.hasNotificationPermission) }
        set { defaults.set(newValue, forKey: Key.hasNotificationPermission) }
    }

    // MARK: - Premium

    var isPremium: Bool {
        get { defaults.bool(forKey: Key.isPremium) }
        set { defaults.set(newValue, forKey: Key.isPremium) }
    }

    // MARK: - Profile

    var displayName: String {
        get { defaults.string(forKey: Key.displayName) ?? "" }
        set { defaults.set(newValue, forKey: Key.displayName) }
    }

    var dailyScreenTimeTarget: Double {
        get {
            let val = defaults.double(forKey: Key.dailyScreenTimeTarget)
            return val > 0 ? val : 4.0 // default 4 hours
        }
        set { defaults.set(newValue, forKey: Key.dailyScreenTimeTarget) }
    }

    // MARK: - Appearance

    var selectedTheme: String {
        get { defaults.string(forKey: Key.selectedTheme) ?? "system" }
        set { defaults.set(newValue, forKey: Key.selectedTheme) }
    }

    var accentColor: String {
        get { defaults.string(forKey: Key.accentColor) ?? "purple" }
        set { defaults.set(newValue, forKey: Key.accentColor) }
    }

    // MARK: - Gamification

    var currentLevel: Int {
        get { max(defaults.integer(forKey: Key.currentLevel), 1) }
        set { defaults.set(newValue, forKey: Key.currentLevel) }
    }

    var currentXP: Int {
        get { defaults.integer(forKey: Key.currentXP) }
        set { defaults.set(newValue, forKey: Key.currentXP) }
    }

    var totalSessionsCompleted: Int {
        get { defaults.integer(forKey: Key.totalSessionsCompleted) }
        set { defaults.set(newValue, forKey: Key.totalSessionsCompleted) }
    }

    var bestStreakLength: Int {
        get { defaults.integer(forKey: Key.bestStreakLength) }
        set { defaults.set(newValue, forKey: Key.bestStreakLength) }
    }

    var totalFocusMinutes: Int {
        get { defaults.integer(forKey: Key.totalFocusMinutes) }
        set { defaults.set(newValue, forKey: Key.totalFocusMinutes) }
    }

    var memberSinceDate: Date? {
        get { defaults.object(forKey: Key.memberSinceDate) as? Date }
        set { defaults.set(newValue, forKey: Key.memberSinceDate) }
    }

    // MARK: - Streak

    var lastActiveDate: Date? {
        get { defaults.object(forKey: Key.lastActiveDate) as? Date }
        set { defaults.set(newValue, forKey: Key.lastActiveDate) }
    }

    var currentStreakLength: Int {
        get { defaults.integer(forKey: Key.currentStreakLength) }
        set { defaults.set(newValue, forKey: Key.currentStreakLength) }
    }

    var streakFreezeCount: Int {
        get { defaults.integer(forKey: Key.streakFreezeCount) }
        set { defaults.set(newValue, forKey: Key.streakFreezeCount) }
    }

    // MARK: - Notifications

    var dailyReminderTime: Date? {
        get { defaults.object(forKey: Key.dailyReminderTime) as? Date }
        set { defaults.set(newValue, forKey: Key.dailyReminderTime) }
    }

    // MARK: - Active Session

    var activeSessionStartedAt: Date? {
        get { defaults.object(forKey: Key.activeSessionStartedAt) as? Date }
        set { defaults.set(newValue, forKey: Key.activeSessionStartedAt) }
    }

    var activeSessionTargetDuration: Int {
        get { defaults.integer(forKey: Key.activeSessionTargetDuration) }
        set { defaults.set(newValue, forKey: Key.activeSessionTargetDuration) }
    }

    var activeSessionMode: String? {
        get { defaults.string(forKey: Key.activeSessionMode) }
        set { defaults.set(newValue, forKey: Key.activeSessionMode) }
    }

    var activeSessionTag: String? {
        get { defaults.string(forKey: Key.activeSessionTag) }
        set { defaults.set(newValue, forKey: Key.activeSessionTag) }
    }

    // MARK: - Blocking Settings

    var defaultBlockingStrictness: String {
        get { defaults.string(forKey: Key.defaultBlockingStrictness) ?? "normal" }
        set { defaults.set(newValue, forKey: Key.defaultBlockingStrictness) }
    }

    var interventionDuration: Int {
        get {
            let val = defaults.integer(forKey: Key.interventionDuration)
            return val > 0 ? val : 12
        }
        set { defaults.set(newValue, forKey: Key.interventionDuration) }
    }

    // MARK: - Shared (App Group) — for extensions

    func setShared(_ value: Any?, forKey key: String) {
        sharedDefaults.set(value, forKey: key)
    }

    func sharedValue(forKey key: String) -> Any? {
        sharedDefaults.object(forKey: key)
    }

    // MARK: - Reset

    func resetAll() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
    }
}
