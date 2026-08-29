import CoreData

@objc(DailyStatsEntity)
public class DailyStatsEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var totalFocusMinutes: Double
    @NSManaged public var sessionsCompleted: Int32
    @NSManaged public var focusScore: Int32
}

extension DailyStatsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyStatsEntity> {
        NSFetchRequest<DailyStatsEntity>(entityName: "DailyStatsEntity")
    }

    func toDomain() -> DailyStatsRecord {
        DailyStatsRecord(
            id: id ?? UUID(),
            date: date ?? .now,
            totalFocusTime: totalFocusMinutes,
            sessionsCompleted: Int(sessionsCompleted),
            focusScore: Int(focusScore)
        )
    }

    static func create(from record: DailyStatsRecord, context: NSManagedObjectContext) -> DailyStatsEntity {
        let entity = DailyStatsEntity(context: context)
        entity.id = record.id
        entity.date = record.date
        entity.totalFocusMinutes = record.totalFocusTime
        entity.sessionsCompleted = Int32(record.sessionsCompleted)
        entity.focusScore = Int32(record.focusScore)
        return entity
    }
}
