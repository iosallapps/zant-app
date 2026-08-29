import Foundation

/// Generates and tracks daily/weekly challenges with JSON persistence.
actor ChallengeService: ChallengeServiceProtocol {

    static let shared = ChallengeService()

    private let storage = JSONFileStorage.shared
    private let storageKey = "daily_challenges"

    private var cachedChallenges: [Challenge] = []
    private var cacheDate: Date?
    private var didLoadFromDisk = false

    private init() {}

    private func loadFromDiskIfNeeded() async {
        guard !didLoadFromDisk else { return }
        didLoadFromDisk = true

        let saved = await storage.load([Challenge].self, from: storageKey)
        if !saved.isEmpty {
            cachedChallenges = saved
            cacheDate = Calendar.current.startOfDay(for: saved.first?.startDate ?? .distantPast)
        }
    }

    func generateDailyChallenges() async -> [Challenge] {
        await loadFromDiskIfNeeded()

        let today = Calendar.current.startOfDay(for: .now)

        // Return cached if from today
        if cacheDate == today, !cachedChallenges.isEmpty {
            return cachedChallenges
        }

        // Generate new challenges for today
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: today) else { return cachedChallenges }

        let challenges = [
            Challenge(
                identifier: .focusStarter,
                type: .daily,
                title: "Focus Starter",
                description: "Complete 1 focus session today",
                targetValue: 1,
                startDate: today,
                endDate: endOfDay
            ),
            Challenge(
                identifier: .deepWorker,
                type: .daily,
                title: "Deep Worker",
                description: "Accumulate 30 minutes of focus time",
                targetValue: 30,
                startDate: today,
                endDate: endOfDay
            ),
            Challenge(
                identifier: .screenLimit,
                type: .daily,
                title: "Screen Limit",
                description: "Stay under your daily screen time target",
                targetValue: 1,
                currentValue: 0,
                startDate: today,
                endDate: endOfDay
            ),
        ]

        cachedChallenges = challenges
        cacheDate = today
        await persist()

        return challenges
    }

    func updateProgress(for challengeID: UUID, value: Double) async {
        await loadFromDiskIfNeeded()

        guard let index = cachedChallenges.firstIndex(where: { $0.id == challengeID }) else { return }

        // Copy-on-write: read, create updated copy, replace
        var updated = cachedChallenges[index]
        updated.currentValue += value
        if updated.currentValue >= updated.targetValue {
            updated.isCompleted = true
        }
        cachedChallenges[index] = updated

        await persist()
    }

    func completedChallenges() async -> [Challenge] {
        await loadFromDiskIfNeeded()
        return cachedChallenges.filter(\.isCompleted)
    }

    // MARK: - Private

    private func persist() async {
        await storage.save(cachedChallenges, to: storageKey)
    }
}
