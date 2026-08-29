import CoreData

final class StatsRepository: StatsRepositoryProtocol, @unchecked Sendable {

    static let shared = StatsRepository()

    private let persistence: PersistenceController

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    func saveDaily(stats: DailyStatsRecord) async throws {
        let context = persistence.newBackgroundContext()
        try await context.perform {
            let startOfDay = Calendar.current.startOfDay(for: stats.date)
            guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return }

            // Upsert: find existing or create new
            let request = DailyStatsEntity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

            if let existing = try context.fetch(request).first {
                existing.totalFocusMinutes = stats.totalFocusTime
                existing.sessionsCompleted = Int32(stats.sessionsCompleted)
                existing.focusScore = Int32(stats.focusScore)
            } else {
                _ = DailyStatsEntity.create(from: stats, context: context)
            }

            try context.save()
        }
    }

    func fetchStats(for date: Date) async throws -> DailyStatsRecord? {
        let context = persistence.newBackgroundContext()
        return try await context.perform {
            let startOfDay = Calendar.current.startOfDay(for: date)
            guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }

            let request = DailyStatsEntity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

            return try context.fetch(request).first?.toDomain()
        }
    }

    func fetchStats(from: Date, to: Date) async throws -> [DailyStatsRecord] {
        let context = persistence.newBackgroundContext()
        return try await context.perform {
            let request = DailyStatsEntity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", from as NSDate, to as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            return try context.fetch(request).map { $0.toDomain() }
        }
    }
}
