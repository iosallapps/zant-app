import Combine
import CoreData
import SwiftData
import os

/// Core Data stack configured for App Group container (shared with extensions).
final class PersistenceController: ObservableObject {

    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.zant", category: "PersistenceController")

    let container: NSPersistentContainer
    let swiftDataContainer: ModelContainer
    @Published var persistenceError: Error?

    init(inMemory: Bool = false) {
        // SwiftData setup first (required before Core Data)
        let schema = Schema([
            FocusSession.self
        ])

        let modelConfiguration: ModelConfiguration
        if inMemory {
            modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        } else {
            // Use App Group container
            if let appGroupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
            ) {
                let storeURL = appGroupURL.appendingPathComponent("SwiftData.sqlite")
                modelConfiguration = ModelConfiguration(url: storeURL)
            } else {
                modelConfiguration = ModelConfiguration()
            }
        }

        do {
            swiftDataContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Core Data setup
        container = NSPersistentContainer(name: "Zant")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Use App Group container for extension access
            if let appGroupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
            ) {
                let storeURL = appGroupURL.appendingPathComponent("Zant.sqlite")
                let description = NSPersistentStoreDescription(url: storeURL)
                description.shouldMigrateStoreAutomatically = true
                description.shouldInferMappingModelAutomatically = true
                container.persistentStoreDescriptions = [description]
            }
        }

        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                // Log the error and expose it for AppState to observe.
                Self.logger.error("Failed to load store: \(error.localizedDescription), \(error.userInfo)")
                DispatchQueue.main.async {
                    self?.persistenceError = error
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Convenience

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            Self.logger.error("Save failed: \(error.localizedDescription)")
        }
    }
}
