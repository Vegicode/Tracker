//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Mac on 03.12.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let uiColorSort = UIColorSort()

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try performSync { context in
            Result {
                let trackerRecordCoreData = TrackerRecordCoreData(context: context)
                updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
                try context.save()
            }
        }
    }
    
    func updateExistingTrackerRecord(_ trackerRecordCorData: TrackerRecordCoreData, with record: TrackerRecord) {
        trackerRecordCorData.date = record.date
        trackerRecordCorData.trackerID = record.trackerID
    }
    
    func fetchAllTrackerRecords() throws -> [TrackerRecord] {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                let trackerRecordCoreDataList = try context.fetch(fetchRequest)
                
                return trackerRecordCoreDataList.compactMap { trackerRecordCoreData in
                    guard let date = trackerRecordCoreData.date,
                          let trackerID = trackerRecordCoreData.trackerID else { return nil }
                    return TrackerRecord(trackerID: trackerID, date: date)
                }
            }
        }
    }
    func fetchTrackerRecord(by trackerID: UUID) throws -> TrackerRecord? {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)
                
                guard let trackerRecordCoreData = try context.fetch(fetchRequest).first else {
                    return nil
                }

                guard let date = trackerRecordCoreData.date,
                      let trackerID = trackerRecordCoreData.trackerID else { return nil }

                return TrackerRecord(trackerID: trackerID, date: date)
            }
        }
    }
    func deleteTrackerRecord(by trackerID: UUID) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)

                if let trackerRecordCoreData = try context.fetch(fetchRequest).first {
                    context.delete(trackerRecordCoreData)
                    try context.save()
                }
            }
        }
    }
    
    private func performSync<E>(_ action: (NSManagedObjectContext) -> Result<E, Error>) throws -> E {
        let context = self.context
        var result: Result<E, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
}
