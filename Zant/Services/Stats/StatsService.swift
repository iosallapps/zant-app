import Foundation
import SwiftData

// MARK: - Enhanced Stats DTO

struct EnhancedSessionStatsDTO {
    let totalSessions: Int
    let totalHours: Double
    let currentStreak: Int
    let longestStreak: Int
    let sessionsThisWeek: Int
    let hoursThisWeek: Double
    let activeDays: Set<Date>
    let recentSessions: [FocusSession]
    let sessionsByTag: [SessionTag: Int]
    let averageSessionDuration: Int
}

struct WeeklyStatsDTO {
    let days: [Date]
    let minutes: [Int]
    let sessions: [Int]
}

// MARK: - Stats Service

final class StatsService {

    private let modelContext: ModelContext
    private let calendar: Calendar

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.calendar = Calendar.current
    }

    // MARK: - Aggregate Stats

    func getSessionStats() async throws -> EnhancedSessionStatsDTO {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.completed },
            sortBy: [SortDescriptor(\.endDate, order: .reverse)]
        )

        let sessions = try modelContext.fetch(descriptor)

        let totalSessions = sessions.count
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        let totalHours = Double(totalMinutes) / 60.0

        let currentStreak = calculateCurrentStreak(from: sessions)
        let longestStreak = calculateLongestStreak(from: sessions)

        let weekStart = calendar.date(byAdding: .day, value: -7, to: Date())!
        let sessionsThisWeek = sessions.filter { $0.endDate >= weekStart }
        let weekSessionCount = sessionsThisWeek.count
        let weekMinutes = sessionsThisWeek.reduce(0) { $0 + $1.durationMinutes }
        let weekHours = Double(weekMinutes) / 60.0

        let activeDays = Set(sessions.map { calendar.startOfDay(for: $0.endDate) })

        let recentSessions = Array(sessions.prefix(10))

        // Group by tag
        var sessionsByTag: [SessionTag: Int] = [:]
        for session in sessions {
            if let tag = SessionTag(rawValue: session.tag) {
                sessionsByTag[tag, default: 0] += 1
            }
        }

        let averageDuration = totalSessions > 0 ? totalMinutes / totalSessions : 0

        return EnhancedSessionStatsDTO(
            totalSessions: totalSessions,
            totalHours: totalHours,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            sessionsThisWeek: weekSessionCount,
            hoursThisWeek: weekHours,
            activeDays: activeDays,
            recentSessions: recentSessions,
            sessionsByTag: sessionsByTag,
            averageSessionDuration: averageDuration
        )
    }

    // MARK: - Weekly Stats

    func getWeeklyStats() async throws -> WeeklyStatsDTO {
        let weekStart = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date()))!

        var days: [Date] = []
        var minutes: [Int] = []
        var sessionCounts: [Int] = []

        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                continue
            }

            let dayStart = calendar.startOfDay(for: day)
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }

            let descriptor = FetchDescriptor<FocusSession>(
                predicate: #Predicate { session in
                    session.completed &&
                    session.endDate >= dayStart &&
                    session.endDate < dayEnd
                }
            )

            let sessionsForDay = try modelContext.fetch(descriptor)
            let totalMinutes = sessionsForDay.reduce(0) { $0 + $1.durationMinutes }

            days.append(day)
            minutes.append(totalMinutes)
            sessionCounts.append(sessionsForDay.count)
        }

        return WeeklyStatsDTO(
            days: days,
            minutes: minutes,
            sessions: sessionCounts
        )
    }

    // MARK: - Today Stats

    func getTodayStats() async throws -> (sessions: Int, minutes: Int) {
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.completed &&
                session.endDate >= todayStart &&
                session.endDate < todayEnd
            }
        )

        let sessions = try modelContext.fetch(descriptor)
        let sessionCount = sessions.count
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }

        return (sessionCount, totalMinutes)
    }

    // MARK: - Streak Calculation

    private func calculateCurrentStreak(from sessions: [FocusSession]) -> Int {
        let activeDays = Set(sessions.map { calendar.startOfDay(for: $0.endDate) })

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Grace period: if before 4am, count yesterday as "today"
        let now = Date()
        let components = calendar.dateComponents([.hour], from: now)
        if let hour = components.hour, hour < 4 {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        while activeDays.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    private func calculateLongestStreak(from sessions: [FocusSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }

        let sortedDays = Set(sessions.map { calendar.startOfDay(for: $0.endDate) })
            .sorted()

        var longestStreak = 1
        var currentStreak = 1

        for i in 1..<sortedDays.count {
            let previousDay = sortedDays[i - 1]
            let currentDay = sortedDays[i]

            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDay),
               calendar.isDate(nextDay, inSameDayAs: currentDay) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return longestStreak
    }

    // MARK: - Most Productive Time

    func getMostProductiveTimeOfDay() async throws -> String {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.completed }
        )

        let sessions = try modelContext.fetch(descriptor)

        var hourCounts: [Int: Int] = [:]

        for session in sessions {
            let hour = calendar.component(.hour, from: session.startDate)
            hourCounts[hour, default: 0] += 1
        }

        guard let mostProductiveHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return "N/A"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "ha"

        let date = calendar.date(bySettingHour: mostProductiveHour, minute: 0, second: 0, of: Date())!
        return formatter.string(from: date).lowercased()
    }

    // MARK: - Focus Score

    func calculateFocusScore(sessions: Int, minutes: Int, streak: Int) -> Int {
        let sessionPoints = sessions * 10
        let minutePoints = minutes / 5
        let streakBonus = min(streak * 20, 200)

        return min(sessionPoints + minutePoints + streakBonus, 100)
    }
}
