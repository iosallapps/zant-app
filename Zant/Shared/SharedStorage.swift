import Foundation

// MARK: - Shared Storage

/// Shared storage for communication between main app and extensions using App Groups.
/// All targets (app + extensions) can read/write to this storage.
final class SharedStorage {

    // MARK: - Singleton

    static let shared = SharedStorage()

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Initialization

    private init() {
        guard let defaults = UserDefaults(suiteName: "group.iosallapps.Zant") else {
            fatalError("Failed to initialize UserDefaults with App Group suite name")
        }
        self.defaults = defaults
    }

    // MARK: - Keys

    private enum Keys {
        static let activeSessionEndTime = "activeSessionEndTime"
        static let activeSessionDuration = "activeSessionDuration"
        static let activeSessionTag = "activeSessionTag"
        static let blockedAppTokens = "blockedAppTokens"
        static let currentStreak = "currentStreak"
        static let lastActiveDate = "lastActiveDate"
        static let isProUser = "isProUser"
        static let sessionStartTime = "sessionStartTime"
    }

    // MARK: - Active Session State

    /// End time of currently active session (nil if no session active)
    var activeSessionEndTime: Date? {
        get { defaults.object(forKey: Keys.activeSessionEndTime) as? Date }
        set { defaults.set(newValue, forKey: Keys.activeSessionEndTime) }
    }

    /// Duration in minutes of active session
    var activeSessionDuration: Int {
        get { defaults.integer(forKey: Keys.activeSessionDuration) }
        set { defaults.set(newValue, forKey: Keys.activeSessionDuration) }
    }

    /// Tag of active session (e.g., "Work", "Study")
    var activeSessionTag: String? {
        get { defaults.string(forKey: Keys.activeSessionTag) }
        set { defaults.set(newValue, forKey: Keys.activeSessionTag) }
    }

    /// Start time of active session
    var sessionStartTime: Date? {
        get { defaults.object(forKey: Keys.sessionStartTime) as? Date }
        set { defaults.set(newValue, forKey: Keys.sessionStartTime) }
    }

    // MARK: - Blocked Apps

    /// Array of blocked app token strings
    var blockedAppTokens: [String] {
        get { defaults.stringArray(forKey: Keys.blockedAppTokens) ?? [] }
        set { defaults.set(newValue, forKey: Keys.blockedAppTokens) }
    }

    // MARK: - Streak Data

    /// Current streak count
    var currentStreak: Int {
        get { defaults.integer(forKey: Keys.currentStreak) }
        set { defaults.set(newValue, forKey: Keys.currentStreak) }
    }

    /// Last date user had an active session (for shield screen display)
    var lastActiveDate: Date? {
        get { defaults.object(forKey: Keys.lastActiveDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastActiveDate) }
    }

    // MARK: - Subscription State

    /// Whether user has active PRO subscription
    var isProUser: Bool {
        get { defaults.bool(forKey: Keys.isProUser) }
        set { defaults.set(newValue, forKey: Keys.isProUser) }
    }

    // MARK: - Helper Methods

    /// Clear all session-related data
    func clearActiveSession() {
        activeSessionEndTime = nil
        activeSessionDuration = 0
        activeSessionTag = nil
        sessionStartTime = nil
        blockedAppTokens = []
    }

    /// Check if there's an active session
    var hasActiveSession: Bool {
        guard let endTime = activeSessionEndTime else { return false }
        return endTime > Date()
    }

    /// Get remaining time in seconds for active session
    var remainingSeconds: Int {
        guard let endTime = activeSessionEndTime else { return 0 }
        return max(0, Int(endTime.timeIntervalSinceNow))
    }

    /// Get formatted remaining time string (e.g., "15 min")
    var formattedRemainingTime: String {
        let seconds = remainingSeconds
        let minutes = seconds / 60

        if minutes > 0 {
            return "\(minutes) min"
        } else if seconds > 0 {
            return "\(seconds) sec"
        } else {
            return "Completed"
        }
    }

    /// Synchronize changes immediately (useful before app termination)
    func synchronize() {
        defaults.synchronize()
    }
}

// MARK: - Session DTO

/// Data transfer object for session state
struct ActiveSessionDTO: Codable {
    let endTime: Date
    let duration: Int
    let tag: String
    let blockedAppTokens: [String]
    let startTime: Date

    /// Create DTO from current shared storage
    static func fromSharedStorage() -> ActiveSessionDTO? {
        let storage = SharedStorage.shared

        guard let endTime = storage.activeSessionEndTime,
              let tag = storage.activeSessionTag,
              let startTime = storage.sessionStartTime else {
            return nil
        }

        return ActiveSessionDTO(
            endTime: endTime,
            duration: storage.activeSessionDuration,
            tag: tag,
            blockedAppTokens: storage.blockedAppTokens,
            startTime: startTime
        )
    }

    /// Save DTO to shared storage
    func saveToSharedStorage() {
        let storage = SharedStorage.shared
        storage.activeSessionEndTime = endTime
        storage.activeSessionDuration = duration
        storage.activeSessionTag = tag
        storage.blockedAppTokens = blockedAppTokens
        storage.sessionStartTime = startTime
        storage.synchronize()
    }
}
