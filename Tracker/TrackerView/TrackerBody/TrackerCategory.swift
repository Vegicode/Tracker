//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Mac on 20.11.2024.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    init?(from categoryCoreData: TrackerCategoryCoreData) {
        guard let title = categoryCoreData.title
        else {
            return nil
        }
        
        let trackerList: [Tracker] = (categoryCoreData.trackers as? Set<TrackerCoreData>)?.compactMap { Tracker(from: $0) } ?? []
        
        self.title = title
        self.trackers = Array(trackerList)
    }
}
