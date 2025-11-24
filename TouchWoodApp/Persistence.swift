import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleRitual = Ritual(context: viewContext)
        sampleRitual.id = UUID()
        sampleRitual.name = "Knock on Wood"
        sampleRitual.ritualDescription = "Tap wood for good luck"
        sampleRitual.icon = "tree.fill"
        sampleRitual.isCustom = false
        sampleRitual.isFavorite = true
        sampleRitual.createdAt = Date()
        
        let sampleLog = RitualLog(context: viewContext)
        sampleLog.id = UUID()
        sampleLog.timestamp = Date()
        sampleLog.mood = 4
        sampleLog.ritual = sampleRitual
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TouchWoodApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveContext() {
        save()
    }
}
