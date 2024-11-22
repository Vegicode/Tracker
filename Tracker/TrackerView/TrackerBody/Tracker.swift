//
//  Tracker.swift
//  Tracker
//
//  Created by Mac on 20.11.2024.
//

import UIKit

struct Tracker{
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let type: TrackerType
 
}
