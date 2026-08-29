import Foundation
import SwiftData
import Observation

// MARK: - Active Session View Model

@Observable
final class ActiveSessionViewModelV2 {

    // MARK: - Published State

    private(set) var sessionState: ActiveSessionStateDTO?
    private(set) var remainingTime: String = "25:00"
    private(set) var progress: Double = 0.0
    private(set) var isStopping: Bool = false
    private(set) var showCompletionCelebration: Bool = false

    // MARK: - Dependencies

    private let timerService: TimerService
    private let appState: AppState
    private let analyticsService: AnalyticsService

    // MARK: - Private Properties

    private var updateTimer: Timer?

    // MARK: - Initialization

    init(
        appState: AppState,
        timerService: TimerService,
        analyticsService: AnalyticsService = .shared
    ) {
        self.appState = appState
        self.timerService = timerService
        self.analyticsService = analyticsService
    }

    // MARK: - Lifecycle

    func onAppear() {
        startUpdating()
    }

    func onDisappear() {
        stopUpdating()
    }

    // MARK: - Computed Properties

    var blockedAppsCount: Int {
        SharedStorage.shared.blockedAppTokens.count
    }

    var sessionTag: SessionTag {
        if let tagString = SharedStorage.shared.activeSessionTag,
           let tag = SessionTag(rawValue: tagString) {
            return tag
        }
        return .focus
    }

    var formattedProgress: String {
        String(format: "%.0f%%", progress * 100)
    }

    // MARK: - Actions

    @MainActor
    func stopSession() async {
        guard !isStopping else { return }

        isStopping = true

        // Show confirmation alert
        // (In actual implementation, this would be handled by the view)

        await timerService.stopSession()

        // Update app state
        appState.activeSessionStartedAt = nil

        // Track analytics
        let remaining = sessionState?.remainingSeconds ?? 0
        analyticsService.track(.sessionAbandoned(remainingMinutes: remaining / 60))

        isStopping = false

        // Haptic feedback
        HapticManager.warning()
    }

    @MainActor
    func takeBreak() {
        // TODO: Implement break functionality in v1.1
        analyticsService.track(.breakTaken)
        HapticManager.light()
    }

    // MARK: - Private Methods

    private func startUpdating() {
        // Initial update
        updateSessionState()

        // Start timer for periodic updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateSessionState()
        }
    }

    private func stopUpdating() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func updateSessionState() {
        // Get current session state from timer service
        if let state = timerService.currentSessionState {
            self.sessionState = state
            self.remainingTime = state.formattedRemainingTime
            self.progress = state.progress

            // Check for completion
            if state.isCompleted && !showCompletionCelebration {
                handleSessionCompletion()
            }
        } else {
            // No active session - this view should close
            self.sessionState = nil
        }
    }

    @MainActor
    private func handleSessionCompletion() {
        showCompletionCelebration = true

        // Celebration haptic
        HapticManager.success()

        // Track analytics
        analyticsService.track(.sessionCompleted)

        // Auto-dismiss after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            appState.activeSessionStartedAt = nil
        }
    }
}

// MARK: - Preview Helper

extension ActiveSessionViewModelV2 {
    static func preview(appState: AppState, modelContext: ModelContext) -> ActiveSessionViewModelV2 {
        let timerService = TimerService(modelContext: modelContext)
        return ActiveSessionViewModelV2(appState: appState, timerService: timerService)
    }
}
