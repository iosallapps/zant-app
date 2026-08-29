import Foundation

/// Persists blocking rules as JSON in the app group container.
/// Uses JSONFileStorage pattern but through SharedBlockingStorage for cross-process access.
actor BlockingRuleRepository: BlockingRuleRepositoryProtocol {

    static let shared = BlockingRuleRepository()
    private let storage = SharedBlockingStorage.shared

    func save(rule: BlockingRuleRecord) async throws {
        var rules = storage.loadBlockingRules()
        let codable = rule.toCodable()
        rules.append(codable)
        storage.saveBlockingRules(rules)
    }

    func fetchAll() async throws -> [BlockingRuleRecord] {
        storage.loadBlockingRules().map { $0.toDomain() }
    }

    func fetchActive() async throws -> [BlockingRuleRecord] {
        storage.loadBlockingRules()
            .filter(\.isActive)
            .map { $0.toDomain() }
    }

    func delete(ruleID: UUID) async throws {
        var rules = storage.loadBlockingRules()
        rules.removeAll { $0.id == ruleID }
        storage.saveBlockingRules(rules)
    }

    func update(rule: BlockingRuleRecord) async throws {
        var rules = storage.loadBlockingRules()
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule.toCodable()
            storage.saveBlockingRules(rules)
        }
    }
}

// MARK: - Mappers

extension BlockingRuleRecord {
    nonisolated func toCodable() -> CodableBlockingRule {
        CodableBlockingRule(
            id: id,
            name: name,
            isActive: isActive,
            strictness: strictness.rawValue,
            daysOfWeek: Array(daysOfWeek).sorted(),
            startHour: startTime.hour ?? 9,
            startMinute: startTime.minute ?? 0,
            endHour: endTime.hour ?? 17,
            endMinute: endTime.minute ?? 0,
            createdAt: createdAt
        )
    }
}

extension CodableBlockingRule {
    nonisolated func toDomain() -> BlockingRuleRecord {
        BlockingRuleRecord(
            id: id,
            name: name,
            isActive: isActive,
            strictness: BlockingStrictness(rawValue: strictness) ?? .normal,
            daysOfWeek: Set(daysOfWeek),
            startTime: DateComponents(hour: startHour, minute: startMinute),
            endTime: DateComponents(hour: endHour, minute: endMinute),
            createdAt: createdAt
        )
    }
}
