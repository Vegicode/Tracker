//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Mac on 03.12.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let uiColorSort = UIColorSort()
    private let daysValueTransformer = DaysValueTransformer()
    private let trackerTyperValueTransformer = TrackerTypeValueTransformer()
    
    enum TrackerCategoryStoreError: Error {
        case categoryNotFound
        case trackerNotFound
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func performSync<E>(_ action: (NSManagedObjectContext) -> Result<E, Error>)
    throws -> E {
        var result: Result<E, Error>!
        context.performAndWait {
            result = action(context)
        }
        return try result.get()
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.title = tracker.title
            trackerCoreData.color = uiColorSort.hexString(from: tracker.color)
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
            trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
            trackerCoreData.category = categoryCoreData
        }
        try context.save()
    }
    
    func fetchAllCategories() throws -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoryCoreDataList = try context.fetch(fetchRequest)
        
        return categoryCoreDataList.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }
            
            if let trackersSet = categoryCoreData.trackers as? NSSet {
                let trackerCoreDataList = trackersSet.allObjects as? [TrackerCoreData] ?? []
                
                let trackers = trackerCoreDataList.compactMap { trackerCoreData -> Tracker? in
                    guard let id = trackerCoreData.id,
                          let title = trackerCoreData.title,
                          let colorHex = trackerCoreData.color,
                          let emoji = trackerCoreData.emoji,
                          let scheduleData = trackerCoreData.schedule as? NSData,
                          let schedule = DaysValueTransformer().reverseTransformedValue(scheduleData) as? [Weekday],
                          let color = uiColorSort.color(from: colorHex) else { return nil }
                    
                    return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, type: .habbit)
                }
                
                return TrackerCategory(title: title, trackers: trackers)
            }
            
            return nil
        }
    }
    
    
    func updateCategory(_ category: TrackerCategory) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
                
                guard let categoryCoreData = try context.fetch(fetchRequest).first else {
                    throw TrackerCategoryStoreError.categoryNotFound
                }
                categoryCoreData.trackers = nil
                
                
                for tracker in category.trackers {
                    let trackerCoreData = TrackerCoreData(context: context)
                    trackerCoreData.id = tracker.id
                    trackerCoreData.title = tracker.title
                    trackerCoreData.color = uiColorSort.hexString(from: tracker.color)
                    trackerCoreData.emoji = tracker.emoji
                    trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
                    trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
                    trackerCoreData.category = categoryCoreData
                }
                
                try context.save()
            }
        }
    }
    
    func deleteCategory(byTitle title: String) throws {
        try performSync { context in
            Result{
                let fetchRequest:NSFetchRequest<TrackerCategoryCoreData> =
                TrackerCategoryCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@", title)
                
                guard let categoryCoreData = try context.fetch(fetchRequest).first else
                {
                    throw TrackerCategoryStoreError.categoryNotFound
                }
                context.delete(categoryCoreData)
                try context.save()
            }
        }
    }
    
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        try performSync { context in
            Result {
                let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> =
                TrackerCategoryCoreData.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "title == %@", title)
                
                guard let categoryCoreData = try
                        context.fetch(categoryFetchRequest).first else {
                    throw TrackerCategoryStoreError.categoryNotFound
                }
                
                let trackerCoreData = TrackerCoreData(context: context)
                trackerCoreData.id = tracker.id
                trackerCoreData.title = tracker.title
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.color = uiColorSort.hexString(from: tracker.color)
                trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
                trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
                trackerCoreData.category = categoryCoreData
                
                try context.save()
            }
        }
    }
    
    func addCategory(_ categoryTitle: String, toTrackerWithId trackerId: UUID) throws {
        try performSync { context in
            Result {
                let trackerFetchRequest: NSFetchRequest<TrackerCoreData> =
                TrackerCoreData.fetchRequest()
                trackerFetchRequest.predicate = NSPredicate(format: "id == $@", trackerId as CVarArg)
                
                guard let trackerCoreData = try
                        context.fetch(trackerFetchRequest).first else {
                    throw TrackerCategoryStoreError.trackerNotFound
                }
                
                let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> =
                TrackerCategoryCoreData.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
                
                guard let categoryCoreData = try
                        context.fetch(categoryFetchRequest).first else {
                    throw TrackerCategoryStoreError.categoryNotFound
                }
                trackerCoreData.category = categoryCoreData
                
                try context.save()
            }
            
        }
        
    }
    
}
