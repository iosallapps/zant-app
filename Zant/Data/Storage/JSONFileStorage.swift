import Foundation
import os

/// Lightweight JSON file storage for append-only collections (gems, achievements).
/// Uses App Group container so extensions can read the data.
actor JSONFileStorage {

    static let shared = JSONFileStorage()

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.zant", category: "JSONFileStorage")

    private let fileManager = FileManager.default

    private nonisolated var containerURL: URL {
        let fm = FileManager.default
        if let groupURL = fm.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
        ) {
            return groupURL
        }
        if let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsURL
        }
        return fm.temporaryDirectory
    }

    // MARK: - Generic Read/Write

    func load<T: Decodable>(_ type: [T].Type, from filename: String) -> [T] {
        let url = containerURL.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: url.path) else { return [] }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            Self.logger.error("Failed to load \(filename): \(error.localizedDescription)")
            return []
        }
    }

    func save<T: Encodable>(_ items: [T], to filename: String) {
        let url = containerURL.appendingPathComponent(filename)
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: url, options: .atomic)
        } catch {
            Self.logger.error("Failed to save \(filename): \(error.localizedDescription)")
        }
    }

    func append<T: Codable>(_ item: T, to filename: String) {
        var items = load([T].self, from: filename)
        items.append(item)
        save(items, to: filename)
    }

    // MARK: - Gem-Specific

    private let gemsFile = "gems.json"

    func loadGems() -> [Gem] {
        load([Gem].self, from: gemsFile)
    }

    func saveGem(_ gem: Gem) {
        append(gem, to: gemsFile)
    }

    func saveAllGems(_ gems: [Gem]) {
        save(gems, to: gemsFile)
    }

    // MARK: - Crystal-Specific

    private let crystalsFile = "crystals.json"

    func loadCrystals() -> [Crystal] {
        load([Crystal].self, from: crystalsFile)
    }

    func saveCrystal(_ crystal: Crystal) {
        append(crystal, to: crystalsFile)
    }

    func saveAllCrystals(_ crystals: [Crystal]) {
        save(crystals, to: crystalsFile)
    }

    // MARK: - Achievement-Specific

    private let achievementsFile = "achievements.json"

    func loadAchievements() -> [Achievement] {
        load([Achievement].self, from: achievementsFile)
    }

    func saveAchievement(_ achievement: Achievement) {
        append(achievement, to: achievementsFile)
    }

    func saveAllAchievements(_ achievements: [Achievement]) {
        save(achievements, to: achievementsFile)
    }
}
