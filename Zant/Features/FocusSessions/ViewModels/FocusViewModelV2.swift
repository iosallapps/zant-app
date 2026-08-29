import Foundation
import SwiftData
import Observation
#if !targetEnvironment(simulator)
import FamilyControls
#endif

// MARK: - Focus View Model

@Observable
final class FocusViewModelV2 {

    // MARK: - Published State

    private(set) var selectedDuration: Int = 25
    private(set) var selectedTag: SessionTag = .focus
    private(set) var selectedAppCount: Int = 0
    private(set) var enableBreaks: Bool = false
    private(set) var isStarting: Bool = false
    private(set) var errorMessage: String?
    private(set) var showPaywall: Bool = false
    private(set) var paywallSource: PaywallSource = .sessionLimit
    private(set) var remainingFreeSessions: Int?

    // MARK: - App Selection

    #if !targetEnvironment(simulator)
    private(set) var appSelection: FamilyActivitySelection? = nil
    #endif

    // MARK: - Constants

    let durations: [Int] = [5, 15, 25, 45, 60]

    // MARK: - Dependencies

    private let timerService: TimerService
    private let appState: AppState
    private let analyticsService: AnalyticsService
    private let freeTierManager: FreeTierManager
    private let modelContext: ModelContext

    // MARK: - Initialization

    init(
        appState: AppState,
        timerService: TimerService,
        modelContext: ModelContext,
        analyticsService: AnalyticsService = .shared,
        freeTierManager: FreeTierManager = .shared
    ) {
        self.appState = appState
        self.timerService = timerService
        self.modelContext = modelContext
        self.analyticsService = analyticsService
        self.freeTierManager = freeTierManager
    }

    // MARK: - Computed Properties

    var formattedDuration: String {
        "\(selectedDuration):00"
    }

    var canStartSession: Bool {
        !isStarting && selectedAppCount > 0
    }

    var selectedAppsCount: Int {
        selectedAppCount
    }

    // MARK: - Actions

    func selectDuration(_ duration: Int) {
        selectedDuration = duration
        HapticManager.selection()
    }

    func selectTag(_ tag: SessionTag) {
        selectedTag = tag
        HapticManager.selection()
    }

    func toggleBreaks() {
        enableBreaks.toggle()
        HapticManager.selection()
    }

    // Update from FamilyActivityPicker
    func updateSelectedAppsFromSelection(_ selection: Any) {
        #if !targetEnvironment(simulator)
        if let familySelection = selection as? FamilyActivitySelection {
            appSelection = familySelection
            selectedAppCount = familySelection.applicationTokens.count

            // Save selection to AppBlockingService immediately
            Task {
                await AppBlockingService.shared.saveAppSelection(familySelection)
            }
        }
        #else
        selectedAppCount = 0
        #endif
    }

    // MARK: - Session Management

    @MainActor
    func startSession() async {
        guard !isStarting else { return }

        // Check free tier limits
        let (canStart, _) = await freeTierManager.canStartSession(modelContext: modelContext)
        if !canStart {
            // Show hard paywall (session limit reached)
            paywallSource = .sessionLimit
            showPaywall = true
            return
        }

        isStarting = true
        errorMessage = nil

        do {
            // For now, use empty app tokens array
            // The actual blocking will be handled by the existing AppBlockingService
            // which uses FamilyActivitySelection
            let configuration = SessionConfigurationDTO(
                durationMinutes: selectedDuration,
                tag: selectedTag,
                blockedAppTokens: [], // Will be handled differently
                enableBreaks: enableBreaks
            )

            // Start the session
            try await timerService.startSession(configuration: configuration)

            // Update app state
            appState.activeSessionStartedAt = Date()

            // Track analytics
            analyticsService.track(.sessionStarted(
                duration: selectedDuration,
                appsCount: selectedAppCount,
                tag: selectedTag.rawValue
            ))

            // Success haptic
            HapticManager.success()

        } catch {
            errorMessage = "Failed to start session: \(error.localizedDescription)"
            HapticManager.error()
        }

        isStarting = false
    }

    // MARK: - Lifecycle

    func onAppear() async {
        // Load remaining free sessions
        remainingFreeSessions = await freeTierManager.remainingFreeSessions(modelContext: modelContext)

        // Load existing app selection
        #if !targetEnvironment(simulator)
        if let selection = await AppBlockingService.shared.loadAppSelection() {
            appSelection = selection
            selectedAppCount = selection.applicationTokens.count
        }
        #endif
    }

    // MARK: - Validation

    func validateCanStart() -> (canStart: Bool, reason: String?) {
        if selectedAppCount == 0 {
            return (false, "Please select at least one app to block")
        }

        return (true, nil)
    }
    
    // MARK: - Get Selection

    #if !targetEnvironment(simulator)
    func getAppSelection() -> FamilyActivitySelection? {
        return appSelection
    }
    #endif
}

// MARK: - Preview Helper

extension FocusViewModelV2 {
    static func preview(appState: AppState, modelContext: ModelContext) -> FocusViewModelV2 {
        let timerService = TimerService(modelContext: modelContext)
        return FocusViewModelV2(
            appState: appState,
            timerService: timerService,
            modelContext: modelContext
        )
    }
}
