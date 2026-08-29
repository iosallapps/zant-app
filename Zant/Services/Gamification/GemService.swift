import Foundation

/// Manages gem earning, persistence, and queries.
final class GemService: GemServiceProtocol, @unchecked Sendable {

    static let shared = GemService()

    private let storage = JSONFileStorage.shared

    private init() {}

    func earnGem(type: GemType, reason: GemReason) async {
        let gem = Gem(type: type, reason: reason)
        await storage.saveGem(gem)
    }

    func getAllGems() async -> [Gem] {
        await storage.loadGems()
    }

    func gemCount(for type: GemType) async -> Int {
        let gems = await storage.loadGems()
        return gems.filter { $0.type == type }.count
    }

    /// Determines which gem type to award based on session duration.
    static func gemType(forSessionMinutes minutes: Int) -> GemType? {
        if minutes >= 60 { return .amethyst }
        if minutes >= 30 { return .quartz }
        if minutes >= 15 { return .stone }
        return nil
    }
}
