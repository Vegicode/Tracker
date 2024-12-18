//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Mac on 20.11.2024.
//

import UIKit

struct TrackerRecord: Hashable {
    let trackerID: UUID
    let date: Date
}

extension TrackerRecord {
    init?(from trackerRecordEntity: TrackerRecordCoreData) {
        guard
              let trackerID = trackerRecordEntity.trackerID,
              let date = trackerRecordEntity.date
        else {
            return nil
        }
        self.trackerID = trackerID
        self.date = date
    }
}
