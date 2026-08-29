import Foundation
import SwiftData

// MARK: - Focus Session (SwiftData Model)

@Model
final class FocusSession {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var durationMinutes: Int
    var tag: String
    var blockedAppTokens: [String]
    var completed: Bool
    var breaksTaken: Int
    var pausedDuration: Int // seconds spent paused (for future use)

    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        endDate: Date,
        durationMinutes: Int,
        tag: String = "Focus",
        blockedAppTokens: [String] = [],
        completed: Bool = false,
        breaksTaken: Int = 0,
        pausedDuration: Int = 0
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.durationMinutes = durationMinutes
        self.tag = tag
        self.blockedAppTokens = blockedAppTokens
        self.completed = completed
        self.breaksTaken = breaksTaken
        self.pausedDuration = pausedDuration
    }

    /// Actual duration in minutes (accounting for early completion)
    var actualDuration: Int {
        let actualSeconds = endDate.timeIntervalSince(startDate)
        return max(1, Int(actualSeconds / 60))
    }
}

// MARK: - Session Configuration DTO
// Note: SessionTag enum is defined in Core/Protocols/Models.swift

/// Data transfer object for configuring a new session
struct SessionConfigurationDTO {
    let durationMinutes: Int
    let tag: SessionTag
    let blockedAppTokens: [String]
    let enableBreaks: Bool

    init(
        durationMinutes: Int,
        tag: SessionTag = .focus,
        blockedAppTokens: [String] = [],
        enableBreaks: Bool = false
    ) {
        self.durationMinutes = durationMinutes
        self.tag = tag
        self.blockedAppTokens = blockedAppTokens
        self.enableBreaks = enableBreaks
    }
}

// MARK: - Active Session State DTO

/// Current state of an active session
struct ActiveSessionStateDTO {
    let sessionId: UUID
    let startTime: Date
    let endTime: Date
    let durationMinutes: Int
    let tag: SessionTag
    let remainingSeconds: Int
    let progress: Double // 0.0 to 1.0
    let isBreakTime: Bool

    init(
        sessionId: UUID,
        startTime: Date,
        endTime: Date,
        durationMinutes: Int,
        tag: SessionTag,
        isBreakTime: Bool = false
    ) {
        self.sessionId = sessionId
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = durationMinutes
        self.tag = tag
        self.isBreakTime = isBreakTime

        // Calculate remaining and progress
        let totalSeconds = endTime.timeIntervalSince(startTime)
        let elapsedSeconds = Date().timeIntervalSince(startTime)
        self.remainingSeconds = max(0, Int(endTime.timeIntervalSinceNow))
        self.progress = min(1.0, max(0.0, elapsedSeconds / totalSeconds))
    }

    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }

    var isCompleted: Bool {
        remainingSeconds <= 0
    }
}

// MARK: - Session Stats DTO

/// Aggregated statistics for sessions
struct SessionStatsDTO {
    let totalSessions: Int
    let completedSessions: Int
    let totalMinutes: Int
    let averageSessionLength: Int
    let currentStreak: Int
    let longestStreak: Int
    let sessionsToday: Int
    let minutesToday: Int

    static var empty: SessionStatsDTO {
        SessionStatsDTO(
            totalSessions: 0,
            completedSessions: 0,
            totalMinutes: 0,
            averageSessionLength: 0,
            currentStreak: 0,
            longestStreak: 0,
            sessionsToday: 0,
            minutesToday: 0
        )
    }

    var completionRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }
}

// MARK: - Daily Stats DTO

/// Stats for a specific day
struct DailyStatsDTO: Identifiable {
    let id: UUID
    let date: Date
    let sessionCount: Int
    let totalMinutes: Int
    let isActiveDay: Bool // Has at least 1 completed session

    init(date: Date, sessionCount: Int, totalMinutes: Int) {
        self.id = UUID()
        self.date = date
        self.sessionCount = sessionCount
        self.totalMinutes = totalMinutes
        self.isActiveDay = sessionCount > 0
    }
}
