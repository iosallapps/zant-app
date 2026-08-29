import Foundation

/// Manages crystal earning, persistence, and queries.
final class CrystalService: CrystalServiceProtocol, @unchecked Sendable {

    static let shared = CrystalService()

    private let storage = JSONFileStorage.shared

    private init() {}

    func earnCrystal(type: CrystalType, reason: CrystalReason) async {
        let crystal = Crystal(type: type, reason: reason)
        await storage.saveCrystal(crystal)
    }

    func getAllCrystals() async -> [Crystal] {
        await storage.loadCrystals()
    }

    func crystalCount(for type: CrystalType) async -> Int {
        let crystals = await storage.loadCrystals()
        return crystals.filter { $0.type == type }.count
    }

    /// Determines which crystal type to award based on session duration
    /// Progressive unlocking: 5min intervals
    static func crystalType(forSessionMinutes minutes: Int) -> CrystalType? {
        // Calculate level: 15min = level 1, 20min = level 2, etc.
        let level = min(max((minutes + 5) / 5, 1), 20)
        return CrystalType(rawValue: level)
    }

    /// Random crystal drop within a specific tier (for variety)
    static func randomCrystalInTier(_ tier: CrystalTier) -> CrystalType {
        let candidates = CrystalType.allCases.filter { $0.tier == tier }
        return candidates.randomElement() ?? .clearQuartz
    }
}
