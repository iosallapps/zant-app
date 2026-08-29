import Foundation
import SwiftData
import Observation

// MARK: - Timer Service Protocol

protocol TimerServiceProtocol {
    func startSession(configuration: SessionConfigurationDTO) async throws
    func stopSession() async
    func checkForExpiredSession() async
    var currentSessionState: ActiveSessionStateDTO? { get }
}

// MARK: - Timer Service

@Observable
final class TimerService: TimerServiceProtocol {

    // MARK: - Published Properties

    private(set) var currentSessionState: ActiveSessionStateDTO?
    private(set) var isActive: Bool = false
    private(set) var remainingSeconds: Int = 0

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let blockingService: AppBlockingService
    private let sharedStorage: SharedStorage
    private let analyticsService: AnalyticsService?

    // MARK: - Private Properties

    private var timer: Timer?
    private var currentSessionId: UUID?
    private var sessionEndTime: Date?

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        blockingService: AppBlockingService = .shared,
        sharedStorage: SharedStorage = .shared,
        analyticsService: AnalyticsService? = nil
    ) {
        self.modelContext = modelContext
        self.blockingService = blockingService
        self.sharedStorage = sharedStorage
        self.analyticsService = analyticsService
    }

    // MARK: - Public Methods

    /// Start a new focus session
    func startSession(configuration: SessionConfigurationDTO) async throws {
        // Stop any existing session first
        await stopSession()

        let sessionId = UUID()
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(TimeInterval(configuration.durationMinutes * 60))

        // Create session in Core Data
        let session = FocusSession(
            id: sessionId,
            startDate: startTime,
            endDate: endTime,
            durationMinutes: configuration.durationMinutes,
            tag: configuration.tag.rawValue,
            blockedAppTokens: configuration.blockedAppTokens,
            completed: false
        )

        modelContext.insert(session)
        try modelContext.save()

        // Save to shared storage for extensions
        sharedStorage.activeSessionEndTime = endTime
        sharedStorage.sessionStartTime = startTime
        sharedStorage.activeSessionDuration = configuration.durationMinutes
        sharedStorage.activeSessionTag = configuration.tag.rawValue
        sharedStorage.blockedAppTokens = configuration.blockedAppTokens
        sharedStorage.synchronize()

        // Activate app blocking if user has selected apps
        #if !targetEnvironment(simulator)
        if blockingService.hasAppSelection() {
            try await blockingService.blockApps(
                tokens: configuration.blockedAppTokens,
                until: endTime
            )
        }
        #endif

        // Update local state
        self.currentSessionId = sessionId
        self.sessionEndTime = endTime
        self.isActive = true

        // Update session state
        updateSessionState()

        // Start countdown timer
        startTimer()

        // Track analytics
        analyticsService?.track(.sessionStarted(
            duration: configuration.durationMinutes,
            appsCount: configuration.blockedAppTokens.count,
            tag: configuration.tag.rawValue
        ))

        // Trigger haptic
        HapticManager.success()
    }

    /// Stop the current session
    func stopSession() async {
        guard let sessionId = currentSessionId else { return }

        // Stop timer
        timer?.invalidate()
        timer = nil

        // Fetch session from Core Data
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.id == sessionId }
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            if let session = sessions.first {
                // Mark session as completed or abandoned
                let now = Date()
                let wasCompleted = now >= session.endDate

                session.completed = wasCompleted
                session.endDate = min(now, session.endDate)

                try modelContext.save()

                // Track analytics
                if wasCompleted {
                    analyticsService?.track(.sessionCompleted)
                } else {
                    let remaining = Int(session.endDate.timeIntervalSinceNow / 60)
                    analyticsService?.track(.sessionAbandoned(remainingMinutes: max(0, remaining)))
                }
            }
        } catch {
            print("Error stopping session: \(error)")
        }

        // Remove blocking
        await blockingService.removeAllBlocks()

        // Clear shared storage
        sharedStorage.clearActiveSession()

        // Reset local state
        self.currentSessionId = nil
        self.sessionEndTime = nil
        self.isActive = false
        self.currentSessionState = nil
        self.remainingSeconds = 0
    }

    /// Check for expired session on app launch
    func checkForExpiredSession() async {
        guard let endTime = sharedStorage.activeSessionEndTime else {
            return
        }

        let now = Date()

        if now >= endTime {
            // Session expired - complete it
            await completeExpiredSession()
        } else {
            // Session still active - resume it
            await resumeActiveSession()
        }
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateSessionState()
        }
    }

    private func updateSessionState() {
        guard let endTime = sessionEndTime,
              let sessionId = currentSessionId,
              let tagString = sharedStorage.activeSessionTag,
              let tag = SessionTag(rawValue: tagString),
              let startTime = sharedStorage.sessionStartTime else {
            return
        }

        let now = Date()

        if now >= endTime {
            // Session completed
            Task {
                await handleSessionCompletion()
            }
        } else {
            // Update remaining time
            remainingSeconds = max(0, Int(endTime.timeIntervalSinceNow))

            // Create state DTO
            currentSessionState = ActiveSessionStateDTO(
                sessionId: sessionId,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: sharedStorage.activeSessionDuration,
                tag: tag
            )
        }
    }

    private func handleSessionCompletion() async {
        guard let sessionId = currentSessionId else { return }

        // Mark session as completed
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.id == sessionId }
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            if let session = sessions.first {
                session.completed = true
                try modelContext.save()

                // Update streak
                updateStreak()

                // Track analytics
                analyticsService?.track(.sessionCompleted)

                // Celebration haptic
                HapticManager.success()
            }
        } catch {
            print("Error completing session: \(error)")
        }

        // Clean up
        await stopSession()
    }

    private func completeExpiredSession() async {
        // Find session that should have ended
        guard let endTime = sharedStorage.activeSessionEndTime else { return }

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.endDate == endTime && !$0.completed }
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            if let session = sessions.first {
                session.completed = true
                try modelContext.save()

                // Update streak
                updateStreak()
            }
        } catch {
            print("Error completing expired session: \(error)")
        }

        // Clear shared storage
        sharedStorage.clearActiveSession()
        await blockingService.removeAllBlocks()
    }

    private func resumeActiveSession() async {
        guard let endTime = sharedStorage.activeSessionEndTime,
              let _ = sharedStorage.sessionStartTime else {
            return
        }

        // Find the session to resume
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.endDate == endTime && !$0.completed }
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            if let session = sessions.first {
                self.currentSessionId = session.id
                self.sessionEndTime = endTime
                self.isActive = true

                // Resume blocking if user has selected apps
                #if !targetEnvironment(simulator)
                if blockingService.hasAppSelection() {
                    try await blockingService.blockApps(
                        tokens: session.blockedAppTokens,
                        until: endTime
                    )
                }
                #endif

                // Update state and start timer
                updateSessionState()
                startTimer()
            }
        } catch {
            print("Error resuming session: \(error)")
        }
    }

    private func updateStreak() {
        // Calculate new streak based on completed sessions
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.completed },
            sortBy: [SortDescriptor(\.endDate, order: .reverse)]
        )

        do {
            let sessions = try modelContext.fetch(descriptor)
            let streak = calculateStreak(from: sessions)
            sharedStorage.currentStreak = streak
            sharedStorage.lastActiveDate = Date()
            sharedStorage.synchronize()

            // Check for milestone
            if [3, 7, 14, 30, 100].contains(streak) {
                analyticsService?.track(.streakMilestone(days: streak))
            }
        } catch {
            print("Error updating streak: \(error)")
        }
    }

    private func calculateStreak(from sessions: [FocusSession]) -> Int {
        let calendar = Calendar.current

        // Group sessions by day
        let activeDays = Set(sessions.map {
            calendar.startOfDay(for: $0.endDate)
        })

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Grace period: if it's before 4am, count yesterday as "today"
        let now = Date()
        let components = calendar.dateComponents([.hour], from: now)
        if let hour = components.hour, hour < 4 {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        // Count consecutive days backwards
        while activeDays.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }
}

// Note: AnalyticsEvent enum is defined in Services/Analytics/AnalyticsService.swift
