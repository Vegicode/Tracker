//
//  TrackerStore.swift
//  Tracker
//
//  Created by Mac on 02.12.2024.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let uiColorSort = UIColorSort()
    private let daysValueTransformer = DaysValueTransformer()
    private let trackerTypeValueTranformer = TrackerTypeValueTransformer()
    
    enum TrackerStoreError: Error {
        case trackerNotFound
    }
    
    
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }
    
    private func performSync<E>(_ action: (NSManagedObjectContext) -> Result<E, Error>) throws -> E {
        var result: Result<E, Error>!
        context.performAndWait {
            result = action(context)
        }
        return try result.get()
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        try performSync { context in
            Result{
                let trackerCoreData = TrackerCoreData(context: context)
                updateExistingTracker(trackerCoreData, with: tracker)
                try context.save()
            }
        }
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = uiColorSort.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
        trackerCoreData.type = tracker.emoji
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCoreData> =
                TrackerCoreData.fetchRequest()
                let trackerCoreDataList = try context.fetch(fetchRequest)
                return trackerCoreDataList.compactMap { trackerCoreData in self.mapToTracker(trackerCoreData)
                }
            }
        }
    }
    
    func fetchTracker(by id: UUID) throws -> Tracker? {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == $@", id as CVarArg)
                guard let trackerCoreData = try context.fetch(fetchRequest).first else {
                    throw TrackerStoreError.trackerNotFound
                }
                return self.mapToTracker(trackerCoreData)
            }
            
        }
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
                if let trackerCoreData = try context.fetch(fetchRequest).first {
                    updateExistingTracker(trackerCoreData, with: tracker)
                    try context.save()
                } else {
                    throw TrackerStoreError.trackerNotFound
                }
            }
        }
    }
    
    func deleteTracker(by id: UUID) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                if let trackerCoreData = try context.fetch(fetchRequest).first {
                    context.delete(trackerCoreData)
                    try context.save()
                } else {
                    throw TrackerStoreError.trackerNotFound
                }
            }
        }
    }
    
    private func mapToTracker(_ trackerCoreData: TrackerCoreData) -> Tracker? {
        guard
        let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let colorHex = trackerCoreData.color,
            let emoji = trackerCoreData.emoji,
            let scheduleData = trackerCoreData.schedule as? NSData,
            let schedule = daysValueTransformer.reverseTransformedValue(scheduleData) as? [Weekday],
        let color = uiColorSort.color(from: colorHex),
        let type = trackerTypeValueTranformer.reverseTranformedValue(trackerCoreData.type) as? TrackerType
        else { return nil }
        
        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, type: type)
    }
    
}


