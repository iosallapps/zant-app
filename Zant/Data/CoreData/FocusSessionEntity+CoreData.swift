import CoreData

@objc(FocusSessionEntity)
public class FocusSessionEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var startedAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var targetDuration: Int32
    @NSManaged public var actualDuration: Int32
    @NSManaged public var mode: String?
    @NSManaged public var tag: String?
    @NSManaged public var wasCompleted: Bool
    @NSManaged public var gemEarned: Bool
    @NSManaged public var gemType: String?
    @NSManaged public var crystalEarned: Bool
    @NSManaged public var crystalLevel: Int16  // 1-20
}

extension FocusSessionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocusSessionEntity> {
        NSFetchRequest<FocusSessionEntity>(entityName: "FocusSessionEntity")
    }

    func toDomain() -> FocusSessionRecord {
        FocusSessionRecord(
            id: id ?? UUID(),
            startedAt: startedAt ?? .now,
            endedAt: endedAt,
            targetDuration: Int(targetDuration),
            actualDuration: Int(actualDuration),
            mode: FocusMode(rawValue: mode ?? "normal") ?? .normal,
            tag: tag.flatMap { SessionTag(rawValue: $0) },
            wasCompleted: wasCompleted,
            gemEarned: gemEarned,
            gemType: gemType.flatMap { GemType(rawValue: $0) },
            crystalEarned: crystalEarned,
            crystalType: crystalLevel > 0 ? CrystalType(rawValue: Int(crystalLevel)) : nil
        )
    }

    static func create(from record: FocusSessionRecord, context: NSManagedObjectContext) -> FocusSessionEntity {
        let entity = FocusSessionEntity(context: context)
        entity.id = record.id
        entity.startedAt = record.startedAt
        entity.endedAt = record.endedAt
        entity.targetDuration = Int32(record.targetDuration)
        entity.actualDuration = Int32(record.actualDuration)
        entity.mode = record.mode.rawValue
        entity.tag = record.tag?.rawValue
        entity.wasCompleted = record.wasCompleted
        entity.gemEarned = record.gemEarned
        entity.gemType = record.gemType?.rawValue
        entity.crystalEarned = record.crystalEarned
        entity.crystalLevel = Int16(record.crystalType?.rawValue ?? 0)
        return entity
    }
}
