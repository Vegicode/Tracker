//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Mac on 03.12.2024.
//
import Foundation
import CoreData


final class TrackerCategoryStore: NSObject {
    private var context: NSManagedObjectContext {
        return DatabaseManager.shared.persistentContainer.viewContext
    }
    static let shared = TrackerStore()
     override init() {}
    
    enum TrackerCategoryStoreError: Error {
        case categoryNotFound
    }


    
    func createCategory(with category: TrackerCategory) {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = category.title
        categoryEntity.trackers = NSSet()

        do {
            try context.save()
        } catch {
            print("Ошибка при создании категории")
        }
    }
    
    func getCategoryByTitle(_ title: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title),
            title
        )
        request.fetchLimit = 1
        
        do {
            let category = try context.fetch(request)
            return category.first
        } catch {
            print("Failed to find category by title: \(error)")
            return nil
        }
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        do {
            let categoriesCoreDataArray = try context.fetch(fetchRequest)
            let categories = categoriesCoreDataArray
                .compactMap { categoriesCoreData -> TrackerCategory? in
                    decodingCategory(from: categoriesCoreData)
                }
            return categories
        } catch {
            print("❌ Failed to fetch categories: \(error)")
            return []
        }
    }

    // Удалить категорию по названию
    func deleteCategory(byTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        guard let categoryCoreData = try context.fetch(fetchRequest).first else {
            throw TrackerCategoryStoreError.categoryNotFound
        }

        context.delete(categoryCoreData)
        try context.save()
    }
}

extension TrackerCategoryStore {
    private func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title else {
            print("❌ Failed to decode category: title is missing")
            return nil
        }
        guard let trackerCoreDataSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            print("❌ Failed to decode category: trackers data is invalid")
            return nil
        }
        let trackers = trackerCoreDataSet.compactMap { Tracker(from: $0) }
        
        if trackers.isEmpty {
            print("⚠️ Decoded category with no trackers: \(title)")
        }
        return TrackerCategory(title: title, trackers: trackers)
    }
}
