//
//  DataBaseManager.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData
import UIKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    // Контейнер для работы с Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                assertionFailure("Не удалось загрузить хранилище: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Контекст для работы с Core Data
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

}


