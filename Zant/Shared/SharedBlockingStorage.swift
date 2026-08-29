import Foundation

/// Cross-process storage for blocking state and app selection.
/// Uses app group UserDefaults and file container so extensions can read/write.
/// Add this file to ALL target memberships.
final class SharedBlockingStorage: @unchecked Sendable {

    static let shared = SharedBlockingStorage()

    private nonisolated(unsafe) let sharedDefaults: UserDefaults
    private let containerURL: URL

    private init() {
        let fileManager = FileManager.default
        self.sharedDefaults = UserDefaults(suiteName: SharedBlockingConstants.appGroupIdentifier) ?? .standard

        if let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: SharedBlockingConstants.appGroupIdentifier
        ) {
            self.containerURL = groupURL
        } else if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.containerURL = documentsURL
        } else {
            self.containerURL = fileManager.temporaryDirectory
        }
    }

    // MARK: - Blocking State

    func saveBlockingState(_ state: BlockingState) {
        if let data = try? JSONEncoder().encode(state) {
            sharedDefaults.set(data, forKey: SharedBlockingConstants.blockingStateKey)
        }
    }

    func loadBlockingState() -> BlockingState? {
        guard let data = sharedDefaults.data(forKey: SharedBlockingConstants.blockingStateKey) else { return nil }
        return try? JSONDecoder().decode(BlockingState.self, from: data)
    }

    // MARK: - Selected Apps Data

    /// Save the PropertyList-encoded FamilyActivitySelection data.
    func saveSelectedAppsData(_ data: Data) {
        let url = containerURL.appendingPathComponent(SharedBlockingConstants.selectedAppsFilename)
        try? data.write(to: url, options: .atomic)
    }

    /// Load the PropertyList-encoded FamilyActivitySelection data.
    func loadSelectedAppsData() -> Data? {
        let url = containerURL.appendingPathComponent(SharedBlockingConstants.selectedAppsFilename)
        return try? Data(contentsOf: url)
    }

    // MARK: - Blocking Rules (JSON)

    func saveBlockingRules(_ rules: [CodableBlockingRule]) {
        let url = containerURL.appendingPathComponent(SharedBlockingConstants.blockingRulesFilename)
        if let data = try? JSONEncoder().encode(rules) {
            try? data.write(to: url, options: .atomic)
        }
    }

    func loadBlockingRules() -> [CodableBlockingRule] {
        let url = containerURL.appendingPathComponent(SharedBlockingConstants.blockingRulesFilename)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([CodableBlockingRule].self, from: data)) ?? []
    }

    // MARK: - Strictness

    func saveStrictness(_ strictness: String) {
        sharedDefaults.set(strictness, forKey: SharedBlockingConstants.blockingStrictnessKey)
    }

    func loadStrictness() -> String? {
        sharedDefaults.string(forKey: SharedBlockingConstants.blockingStrictnessKey)
    }
}

/// Codable version of BlockingRuleRecord for JSON persistence.
struct CodableBlockingRule: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var isActive: Bool
    var strictness: String // BlockingStrictness.rawValue
    var daysOfWeek: [Int]
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var createdAt: Date
}
