import CoreData

final class SessionRepository: SessionRepositoryProtocol, @unchecked Sendable {

    static let shared = SessionRepository()

    private let persistence: PersistenceController

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    func save(session: FocusSessionRecord) async throws {
        let context = persistence.newBackgroundContext()
        try await context.perform {
            _ = FocusSessionEntity.create(from: session, context: context)
            try context.save()
        }
    }

    func fetchToday() async throws -> [FocusSessionRecord] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) else { return [] }
        return try await fetchSessions(from: startOfToday, to: endOfToday)
    }

    func fetchYesterday() async throws -> [FocusSessionRecord] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday) else { return [] }
        return try await fetchSessions(from: startOfYesterday, to: startOfToday)
    }

    func fetchSessions(for date: Date) async throws -> [FocusSessionRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        return try await fetchSessions(from: startOfDay, to: endOfDay)
    }

    func fetchAll() async throws -> [FocusSessionRecord] {
        let context = persistence.newBackgroundContext()
        return try await context.perform {
            let request = FocusSessionEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]
            return try context.fetch(request).map { $0.toDomain() }
        }
    }

    func totalCompletedSessions() async throws -> Int {
        let context = persistence.newBackgroundContext()
        return try await context.perform {
            let request = FocusSessionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "wasCompleted == YES")
            return try context.count(for: request)
        }
    }

    func totalFocusMinutes() async throws -> Int {
        let context = persistence.newBackgroundContext()
        return try await context.perform {
            let request = FocusSessionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "wasCompleted == YES")
            let sessions = try context.fetch(request)
            let totalSeconds = sessions.reduce(0) { $0 + Int($1.actualDuration) }
            return totalSeconds / 60
        }
    }

    // MARK: - Private

    private func fetchSessions(from startDate: Date, to endDate: Date) async throws -> [FocusSessionRecord] {
        let context = persistence.newBackgroundContext()
        return try await context.perform {
            let request = FocusSessionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "startedAt >= %@ AND startedAt < %@", startDate as NSDate, endDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]
            return try context.fetch(request).map { $0.toDomain() }
        }
    }
}
