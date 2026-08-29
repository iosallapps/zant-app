import SwiftUI
import os
import UserNotifications

@Observable
@MainActor
final class ActiveSessionViewModel {

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.zant", category: "ActiveSessionViewModel")

    // MARK: - State

    var remainingSeconds: Int = 0
    var totalSeconds: Int = 0
    var breakSeconds: Int = 0
    var isOnBreak: Bool = false
    var showStopConfirmation: Bool = false
    var showBreakPicker: Bool = false
    var showConfetti: Bool = false

    var modeName: String {
        appState.activeSessionMode?.capitalized ?? "Focus"
    }

    var modeIcon: String {
        switch appState.activeSessionMode {
        case FocusMode.deepFocus.rawValue: "lock.shield"
        case FocusMode.unbreakable.rawValue: "flame.fill"
        default: "brain.head.profile"
        }
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    var elapsedProgress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    // MARK: - Private

    private var timer: Timer?
    private var breakTimer: Timer?
    private var timerTask: Task<Void, Never>?
    private var isCompleting = false
    private let appState: AppState

    private static let sessionCompleteNotificationID = "zant.session.complete"

    init(appState: AppState) {
        self.appState = appState
    }

    // Timer cleanup is handled by stopTimer() called from view lifecycle

    // MARK: - Setup

    func setup() {
        let target = appState.activeSessionTargetDuration
        totalSeconds = target * 60
        recalculateRemaining()
        scheduleCompletionNotification()
    }

    func recalculateRemaining() {
        guard let startedAt = appState.activeSessionStartedAt else {
            remainingSeconds = 0
            return
        }
        let elapsed = Int(Date().timeIntervalSince(startedAt))
        remainingSeconds = max(totalSeconds - elapsed, 0)

        if remainingSeconds <= 0 {
            Task { await completeSession() }
        }
    }

    // MARK: - Timer

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, !self.isOnBreak else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                }
                if self.remainingSeconds <= 0 {
                    await self.completeSession()
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        breakTimer?.invalidate()
        breakTimer = nil
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Session Completion (Reward Pipeline)

    func completeSession() async {
        guard !isCompleting else { return }
        isCompleting = true
        defer { isCompleting = false }

        stopTimer()
        cancelCompletionNotification()
        HapticManager.success()

        let actualSeconds = totalSeconds - remainingSeconds
        let actualMinutes = actualSeconds / 60

        // 1. Build session record
        var record = FocusSessionRecord(
            startedAt: appState.activeSessionStartedAt ?? .now,
            endedAt: .now,
            targetDuration: totalSeconds,
            actualDuration: actualSeconds,
            mode: FocusMode(rawValue: appState.activeSessionMode ?? "normal") ?? .normal,
            tag: appState.activeSessionTag.flatMap { SessionTag(rawValue: $0) },
            wasCompleted: true
        )

        // 2. Determine gem reward
        if let gemType = gemForDuration(actualMinutes) {
            record.gemEarned = true
            record.gemType = gemType
        }

        // 3. Save session to Core Data FIRST — only award rewards on success
        do {
            try await appState.sessionRepository.save(session: record)
        } catch {
            Self.logger.error("Failed to save session: \(error.localizedDescription)")
            // Don't award gems/streak/XP/challenges if session save failed
            await appState.appBlockingService.removeBlocks()
            clearSession()
            return
        }

        // 4. Award gem (session save succeeded)
        if let gemType = record.gemType {
            await appState.gemService.earnGem(type: gemType, reason: .sessionComplete)
        }

        // 5. Update streak
        await appState.streakService.checkAndUpdateStreak()

        // 6. Award XP (2 per minute)
        let xpAmount = max(actualMinutes * 2, 1)
        _ = appState.levelService.awardXP(xpAmount)

        // 7. Update challenges
        let challenges = await appState.challengeService.generateDailyChallenges()
        if let focusStarter = challenges.first(where: { $0.identifier == .focusStarter }) {
            await appState.challengeService.updateProgress(for: focusStarter.id, value: 1)
        }
        if let deepWorker = challenges.first(where: { $0.identifier == .deepWorker }) {
            await appState.challengeService.updateProgress(for: deepWorker.id, value: Double(actualMinutes))
        }

        // 8. Update quick-access stats
        UserDefaultsManager.shared.totalSessionsCompleted += 1
        UserDefaultsManager.shared.totalFocusMinutes += actualMinutes

        // 9. Update best streak if needed
        let currentStreak = appState.streakService.currentStreakLength()
        if currentStreak > UserDefaultsManager.shared.bestStreakLength {
            UserDefaultsManager.shared.bestStreakLength = currentStreak
        }

        // 10. Remove app blocks
        await appState.appBlockingService.removeBlocks()

        // 11. Clear active session from AppState
        clearSession()

        // 12. Show confetti
        showConfetti = true
    }

    func endSessionEarly() async {
        stopTimer()
        cancelCompletionNotification()

        let actualSeconds = totalSeconds - remainingSeconds
        let actualMinutes = actualSeconds / 60

        let record = FocusSessionRecord(
            startedAt: appState.activeSessionStartedAt ?? .now,
            endedAt: .now,
            targetDuration: totalSeconds,
            actualDuration: actualSeconds,
            mode: FocusMode(rawValue: appState.activeSessionMode ?? "normal") ?? .normal,
            tag: appState.activeSessionTag.flatMap { SessionTag(rawValue: $0) },
            wasCompleted: false
        )

        try? await appState.sessionRepository.save(session: record)

        // Partial XP (1 per minute)
        if actualMinutes > 0 {
            _ = appState.levelService.awardXP(actualMinutes)
            UserDefaultsManager.shared.totalFocusMinutes += actualMinutes
        }

        // Remove blocks for deepFocus; unbreakable blocks persist until original end time
        let mode = FocusMode(rawValue: appState.activeSessionMode ?? "normal") ?? .normal
        if mode == .deepFocus {
            await appState.appBlockingService.removeBlocks()
        } else if mode == .unbreakable, remainingSeconds > 0 {
            // Register a one-shot schedule so the extension removes blocks when time expires
            let expiresAt = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            try? ScheduleBlockingService.shared.registerOneShot(expiresAt: expiresAt)
        }

        clearSession()
    }

    // MARK: - Break

    func startBreak(minutes: Int) {
        withAnimation(DesignTokens.Animation.spring) {
            isOnBreak = true
            appState.isOnBreak = true
        }
        breakSeconds = minutes * 60
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.breakSeconds > 0 {
                    self.breakSeconds -= 1
                } else {
                    self.endBreak()
                }
            }
        }
    }

    func endBreak() {
        breakTimer?.invalidate()
        breakTimer = nil
        withAnimation(DesignTokens.Animation.spring) {
            isOnBreak = false
            appState.isOnBreak = false
            breakSeconds = 0
        }
    }

    // MARK: - Helpers

    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func clearSession() {
        appState.activeSessionStartedAt = nil
        appState.activeSessionMode = nil
        appState.activeSessionTag = nil
        appState.activeSessionTargetDuration = 0
        appState.isOnBreak = false
        isOnBreak = false
    }

    private func gemForDuration(_ minutes: Int) -> GemType? {
        if minutes >= 60 { return .amethyst }
        if minutes >= 30 { return .quartz }
        if minutes >= 15 { return .stone }
        return nil
    }

    // MARK: - Background / Foreground

    func handleEnteredBackground() {
        timer?.invalidate()
        timer = nil
        breakTimer?.invalidate()
        breakTimer = nil
        timerTask?.cancel()
        timerTask = nil
    }

    func handleEnteredForeground() {
        recalculateRemaining()
        if remainingSeconds > 0 {
            startTimer()
            if isOnBreak {
                // Recalculate break time too
                // Break continues to count down even in background
            }
        }
    }

    // MARK: - Completion Notification

    private func scheduleCompletionNotification() {
        guard remainingSeconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "Great work! Your session has finished."
        content.sound = .default

        // Use absolute date to avoid drift from relative timeInterval
        let fireDate = Date.now.addingTimeInterval(TimeInterval(remainingSeconds))
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: Self.sessionCompleteNotificationID,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelCompletionNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.sessionCompleteNotificationID]
        )
    }
}
