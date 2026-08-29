import Foundation
#if !targetEnvironment(simulator)
import FamilyControls
import ManagedSettings
#endif

/// Manages app blocking via ManagedSettingsStore.
/// Applies and removes shields on selected apps for focus sessions.
final class AppBlockingService: AppBlockingServiceProtocol, @unchecked Sendable {

    static let shared = AppBlockingService()
    private let storage = SharedBlockingStorage.shared

    #if !targetEnvironment(simulator)
    private let sessionStore = ManagedSettingsStore(named: .init(SharedBlockingConstants.sessionStoreName))
    #endif

    private init() {}

    // MARK: - Apply / Remove Blocks

    @discardableResult
    func applyBlocks(strictness: BlockingStrictness) async -> Bool {
        #if !targetEnvironment(simulator)
        guard let selection = await loadAppSelection() else { return false }

        sessionStore.shield.applications = selection.applicationTokens
        if !selection.categoryTokens.isEmpty {
            sessionStore.shield.applicationCategories = .specific(selection.categoryTokens)
        }

        let state = BlockingState(
            isBlocking: true,
            sessionMode: nil,
            expiresAt: nil,
            strictness: strictness.rawValue
        )
        storage.saveBlockingState(state)
        storage.saveStrictness(strictness.rawValue)
        return true
        #else
        return true
        #endif
    }

    func removeBlocks() async {
        #if !targetEnvironment(simulator)
        sessionStore.clearAllSettings()
        #endif
        storage.saveBlockingState(BlockingState(isBlocking: false))
    }

    /// Remove all blocks (alias for compatibility)
    func removeAllBlocks() async {
        await removeBlocks()
    }

    func isCurrentlyBlocking() -> Bool {
        storage.loadBlockingState()?.isBlocking ?? false
    }

    // MARK: - Token-based Blocking (for TimerService)

    #if !targetEnvironment(simulator)
    /// Block specific apps by their token strings until a given time
    func blockApps(tokens: [String], until endTime: Date) async throws {
        // For now, we'll use the existing app selection mechanism
        // In a full implementation, you would convert tokens to ApplicationTokens
        // and apply them directly to the ManagedSettingsStore

        // Apply blocks with session mode
        let state = BlockingState(
            isBlocking: true,
            sessionMode: nil,
            expiresAt: endTime,
            strictness: BlockingStrictness.strict.rawValue
        )
        storage.saveBlockingState(state)

        // Apply using existing selection if available
        _ = await applyBlocks(strictness: .strict)
    }
    #else
    /// Simulator stub
    func blockApps(tokens: [String], until endTime: Date) async throws {
        print("📱 [Simulator] Would block \(tokens.count) apps until \(endTime)")
    }
    #endif

    // MARK: - App Selection Persistence

    #if !targetEnvironment(simulator)
    func saveAppSelection(_ selection: FamilyActivitySelection) async {
        if let data = try? PropertyListEncoder().encode(selection) {
            storage.saveSelectedAppsData(data)
        }
    }

    func loadAppSelection() async -> FamilyActivitySelection? {
        guard let data = storage.loadSelectedAppsData() else { return nil }
        return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    func hasAppSelection() -> Bool {
        storage.loadSelectedAppsData() != nil
    }
    #else
    // Simulator stubs
    func saveAppSelection(_ selection: Any) async {}
    func hasAppSelection() -> Bool { true }
    #endif
}
