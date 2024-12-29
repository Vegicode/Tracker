 
import Foundation
import CoreData


extension CDTrackerRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTrackerRecord> {
        return NSFetchRequest<CDTrackerRecord>(entityName: "CDTrackerRecord")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var tracker: CDTracker?

}

extension CDTrackerRecord : Identifiable {

}
