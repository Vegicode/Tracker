//
//  TrackerRecordStore.swift
//  EmojiMixer
//
//  Created by Mac on 27.11.2024.
//
import Foundation

@objc final class TrackerTypeValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let type = value as? TrackerType else { return nil }
        switch type {
        case .habbit:
            return "habbit"
        case .event:
            return "event"
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let typeString = value as? String else { return nil }
        switch typeString {
        case "habbit":
            return TrackerType.habbit
        case "event":
            return TrackerType.event
        default:
            return nil
        }
    }

    static func register() {
        ValueTransformer.setValueTransformer(
            TrackerTypeValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: TrackerTypeValueTransformer.self))
        )
    }
}
