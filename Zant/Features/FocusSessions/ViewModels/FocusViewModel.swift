import SwiftUI

@Observable
@MainActor
final class FocusViewModel {

    // MARK: - State

    var selectedDuration: Int = 25
    var selectedMode: FocusMode = .normal
    var selectedTag: SessionTag = .work

    // MARK: - Constants

    let durations = [15, 25, 30, 45, 60, 90, 120]

    // MARK: - Computed

    var formattedDuration: String {
        String(format: "%d:%02d", selectedDuration, 0)
    }

    // MARK: - Dependencies

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Actions

    func startSession() {
        // Prevent starting a new session while one is already running
        guard appState.activeSessionStartedAt == nil else { return }

        // Ensure TimerService is initialized
        guard let timerService = appState.timerService else {
            print("⚠️ TimerService not initialized")
            fallbackStartSession()
            return
        }

        Task {
            do {
                // Create session configuration
                let config = SessionConfigurationDTO(
                    durationMinutes: selectedDuration,
                    tag: selectedTag,
                    blockedAppTokens: [], // Will be populated from AppBlockingService selection
                    enableBreaks: false // Breaks can be added later
                )

                // Start session via TimerService (handles blocking, persistence, recovery)
                try await timerService.startSession(configuration: config)

                // Update AppState for UI reactivity
                appState.activeSessionStartedAt = Date()
                appState.activeSessionTargetDuration = selectedDuration
                appState.activeSessionMode = selectedMode.rawValue
                appState.activeSessionTag = selectedTag.rawValue

            } catch {
                print("❌ Failed to start session: \(error)")
                // Optionally show error to user
            }
        }
    }

    // MARK: - Fallback (Legacy)

    /// Fallback for when TimerService isn't available (backwards compatibility)
    private func fallbackStartSession() {
        // Apply app blocks for deepFocus/unbreakable modes
        if selectedMode == .deepFocus || selectedMode == .unbreakable {
            if appState.screenTimeService.isAuthorized && appState.appBlockingService.hasAppSelection() {
                Task {
                    let strictness: BlockingStrictness = selectedMode == .unbreakable ? .unbreakable : .strict
                    await appState.appBlockingService.applyBlocks(strictness: strictness)
                }
            }
        }

        appState.activeSessionStartedAt = Date()
        appState.activeSessionTargetDuration = selectedDuration
        appState.activeSessionMode = selectedMode.rawValue
        appState.activeSessionTag = selectedTag.rawValue
    }
}
