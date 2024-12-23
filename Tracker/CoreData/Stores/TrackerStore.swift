//
//  TrackerStore.swift
//  Tracker
//
//  Created by Mac on 02.12.2024.
//

import CoreData
import UIKit

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func addNewTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws
    func getTrackerCoreData(by id: UUID) -> TrackerCoreData?
}

final class TrackerStore: NSObject {
    private var context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    private let uiColorSort = UIColorSort()
    private let daysValueTransformer = DaysValueTransformer()
    private let trackerTypeValueTransformer = TrackerTypeValueTransformer()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    weak var delegate: TrackerStoreDelegate?
    
    enum TrackerStoreError: Error {
        case trackerNotFound
    }
    
    init(context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        fatalError("Unable to retrieve AppDelegate")
    }
        return appDelegate.persistentContainer.viewContext
    }()) {
        self.context = context
    }
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
}

extension TrackerStore: TrackerStoreProtocol {
    var numberOfTrackers: Int { fetchedResultsController.fetchedObjects?.count ?? .zero }
    var numberOfSections: Int { fetchedResultsController.sections?.count ?? .zero }
    func numberOfRowsInSection(_ section: Int) -> Int { fetchedResultsController.sections?[section].numberOfObjects ?? .zero }
    
    func addNewTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws {
        print("Метод addNewTracker вызван")
        guard let categoryCoreData = trackerCategoryStore.getCategoryByTitle(category.title) else {
            print("Категория с названием \(category.title) не найдена.")
            throw TrackerStoreError.trackerNotFound
        }
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = uiColorSort.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.type = trackerTypeValueTransformer.transformedValue(tracker.type) as? String
        trackerCoreData.category = categoryCoreData
        categoryCoreData.addToTrackers(trackerCoreData)
        do {
            try context.save()
            print("Трекер успешно добавлен в базу данных")
            try fetchedResultsController.performFetch()
            print("Обновленные трекеры: \(fetchedResultsController.fetchedObjects ?? [])")
        } catch {
            print("Ошибка при сохранении контекста: \(error.localizedDescription)")
        }
    }
    
    func getTrackerCoreData(by id: UUID) -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "id == %@", id as CVarArg
        )
        
        do {
            try fetchedResultsController.performFetch()
            guard let tracker = fetchedResultsController.fetchedObjects?.first else {
                throw StoreErrors.fetchTrackerError
            }
            
            fetchedResultsController.fetchRequest.predicate = nil
            return tracker
        } catch {
            print("❌ Failed to fetch tracker by UUID: \(error)")
            return nil
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insert = insertedIndexes, let deleted = deletedIndexes else { return }
        
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insert,
            deletedIndexes: deleted
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            guard let indexPath else { return }
            deletedIndexes?.insert(indexPath.item)
        case .insert:
            guard let newIndexPath else { return }
            insertedIndexes?.insert(newIndexPath.item)
        default:
            break
        }
    }
}
