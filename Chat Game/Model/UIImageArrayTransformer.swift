//
//  UIImageArrayTransformer.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/27/23.
//

import UIKit

@objc(UIImageArrayTransformer)
final class UIImageArrayTransformer: ValueTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: UIImageArrayTransformer.self))
    
    static func register() {
        ValueTransformer.setValueTransformer(UIImageArrayTransformer(), forName: Self.name)
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSArray.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let images = value as? NSArray else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: images, requiringSecureCoding: false)
            return data
        }
        catch {
            assertionFailure("Failed to transform MidomiTrack to Data")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            let image = try NSKeyedUnarchiver.unsecureUnarchivedObject(ofClass: NSArray.self, from: data)
            return image
        }
        catch {
            assertionFailure("Failed to transform Data to MidomiTrack")
            return nil
        }
        
    }
}
