//
//  Tracker.swift
//  Tracker
//
//  Created by Mac on 20.11.2024.
//

import UIKit

struct Tracker: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let type: TrackerType
}

extension Tracker {
    init?(from trackerCoreData: TrackerCoreData) {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let hexColor = trackerCoreData.color,
            let color = UIColorSort().color(from: hexColor),
            let emoji = trackerCoreData.emoji,
            let typeRaw = trackerCoreData.type,
            let type = TrackerTypeValueTransformer().reverseTransformedValue(typeRaw) as? TrackerType,
            let schedule = trackerCoreData.schedule as? [Weekday]
        
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.type = type
    }
}
