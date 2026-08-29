import SwiftUI
#if !targetEnvironment(simulator)
import FamilyControls
#endif

@Observable
@MainActor
final class BlockingViewModel {

    // MARK: - State

    #if !targetEnvironment(simulator)
    var selectedApps = FamilyActivitySelection()
    #endif
    var rules: [BlockingRuleRecord] = []
    var isBlocking: Bool = false
    var showAppPicker: Bool = false
    var showScheduleCreator: Bool = false
    var toastMessage: String?
    var errorMessage: String?

    // Schedule creator fields
    var newRuleName: String = ""
    var newRuleStrictness: BlockingStrictness = .normal
    var newRuleStartTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? .now
    var newRuleEndTime = Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) ?? .now
    var newRuleDays: Set<Int> = Set(1...7)

    // MARK: - Dependencies

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Load

    func loadData() async {
        rules = (try? await appState.blockingRuleRepository.fetchAll()) ?? []
        isBlocking = appState.appBlockingService.isCurrentlyBlocking()

        #if !targetEnvironment(simulator)
        if let service = appState.appBlockingService as? AppBlockingService,
           let selection = await service.loadAppSelection() {
            selectedApps = selection
        }
        #endif
    }

    // MARK: - App Selection

    var selectedAppCount: Int {
        #if !targetEnvironment(simulator)
        selectedApps.applicationTokens.count + selectedApps.categoryTokens.count
        #else
        0
        #endif
    }

    func saveAppSelection() async {
        #if !targetEnvironment(simulator)
        if let service = appState.appBlockingService as? AppBlockingService {
            await service.saveAppSelection(selectedApps)
        }
        #endif
        toastMessage = "App selection saved"
    }

    // MARK: - Instant Block / Unblock

    func blockNow() async {
        guard appState.appBlockingService.hasAppSelection() else {
            toastMessage = "Select apps to block first"
            return
        }
        let success = await appState.appBlockingService.applyBlocks(strictness: .normal)
        if success {
            isBlocking = true
        } else {
            toastMessage = "Failed to apply blocks — no apps selected"
        }
    }

    func unblockNow() async {
        await appState.appBlockingService.removeBlocks()
        isBlocking = false
    }

    // MARK: - Schedule Validation

    var canCreateRule: Bool {
        !newRuleDays.isEmpty && newRuleStartTime < newRuleEndTime
    }

    var ruleValidationError: String? {
        if newRuleDays.isEmpty {
            return "Select at least one day"
        }
        if newRuleStartTime >= newRuleEndTime {
            return "End time must be after start time"
        }
        return nil
    }

    // MARK: - Schedule Rules

    func createRule() async {
        guard canCreateRule else {
            toastMessage = ruleValidationError
            return
        }

        let calendar = Calendar.current
        let rule = BlockingRuleRecord(
            name: newRuleName.isEmpty ? "Block Schedule" : newRuleName,
            isActive: true,
            strictness: newRuleStrictness,
            daysOfWeek: newRuleDays,
            startTime: calendar.dateComponents([.hour, .minute], from: newRuleStartTime),
            endTime: calendar.dateComponents([.hour, .minute], from: newRuleEndTime)
        )

        do {
            try await appState.blockingRuleRepository.save(rule: rule)
            try ScheduleBlockingService.shared.registerSchedule(for: rule)
        } catch {
            toastMessage = "Failed to create schedule: \(error.localizedDescription)"
            return
        }

        // Reset form
        newRuleName = ""
        newRuleStrictness = .normal
        newRuleDays = Set(1...7)
        showScheduleCreator = false

        await loadData()
    }

    func toggleRule(_ rule: BlockingRuleRecord) async {
        var updated = rule
        updated.isActive.toggle()

        do {
            try await appState.blockingRuleRepository.update(rule: updated)
        } catch {
            errorMessage = "Failed to update rule: \(error.localizedDescription)"
            return
        }

        if updated.isActive {
            do {
                try ScheduleBlockingService.shared.registerSchedule(for: updated)
            } catch {
                errorMessage = "Failed to register schedule: \(error.localizedDescription)"
            }
        } else {
            ScheduleBlockingService.shared.unregisterSchedule(for: updated.id)
        }

        await loadData()
    }

    func deleteRule(_ ruleID: UUID) async {
        ScheduleBlockingService.shared.unregisterSchedule(for: ruleID)
        try? await appState.blockingRuleRepository.delete(ruleID: ruleID)
        await loadData()
    }
}
