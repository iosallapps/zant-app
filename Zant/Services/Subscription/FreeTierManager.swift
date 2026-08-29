import Foundation
import SwiftData

// MARK: - Free Tier Manager

final class FreeTierManager {

    // MARK: - Singleton

    static let shared = FreeTierManager()

    // MARK: - Constants

    private let dailySessionLimit = 3

    // MARK: - Dependencies

    private let storeKitService: StoreKitService

    // MARK: - Initialization

    private init(storeKitService: StoreKitService = .shared) {
        self.storeKitService = storeKitService
    }

    // MARK: - Public Methods

    /// Check if user can start a new session
    func canStartSession(modelContext: ModelContext) async -> (canStart: Bool, reason: String?) {
        // PRO users have unlimited sessions
        if storeKitService.isPremium {
            return (true, nil)
        }

        // Check today's session count
        let todaySessionCount = await getTodaySessionCount(modelContext: modelContext)

        if todaySessionCount >= dailySessionLimit {
            return (false, "You've reached your daily limit of \(dailySessionLimit) sessions. Upgrade to PRO for unlimited sessions.")
        }

        return (true, nil)
    }

    /// Get remaining free sessions today
    func remainingFreeSessions(modelContext: ModelContext) async -> Int {
        if storeKitService.isPremium {
            return Int.max // Unlimited
        }

        let todaySessionCount = await getTodaySessionCount(modelContext: modelContext)
        return max(0, dailySessionLimit - todaySessionCount)
    }

    /// Check if user should see soft paywall (after first session)
    func shouldShowSoftPaywall(modelContext: ModelContext) async -> Bool {
        // Don't show if already PRO
        if storeKitService.isPremium {
            return false
        }

        // Check if user has completed exactly 1 session
        let totalSessions = await getTotalCompletedSessions(modelContext: modelContext)
        return totalSessions == 1
    }

    // MARK: - Private Methods

    private func getTodaySessionCount(modelContext: ModelContext) async -> Int {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        guard let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart) else {
            return 0
        }

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.completed &&
                session.endDate >= todayStart &&
                session.endDate < todayEnd
            }
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            return sessions.count
        } catch {
            print("Error fetching today's sessions: \(error)")
            return 0
        }
    }

    private func getTotalCompletedSessions(modelContext: ModelContext) async -> Int {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.completed }
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            return sessions.count
        } catch {
            print("Error fetching total sessions: \(error)")
            return 0
        }
    }
}
