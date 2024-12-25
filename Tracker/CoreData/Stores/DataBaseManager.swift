
import CoreData
import UIKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    // Контейнер для работы с Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        
        
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    // Контекст для работы с Core Data
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Ошибка при загрузке хранилища данных: \(error.localizedDescription)")
            }
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            saveContext()
        }
    }
}


