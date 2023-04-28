//
//  NSAttributedStringTransformer.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/27/23.
//

import UIKit

@objc(NSAttributedStringTransformer)
final class NSAttributedStringTransformer: ValueTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: NSAttributedStringTransformer.self))
    
    static func register() {
        ValueTransformer.setValueTransformer(NSAttributedStringTransformer(), forName: Self.name)
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSAttributedString.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let attributedString = value as? NSAttributedString else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false)
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
            let attributedString = try NSKeyedUnarchiver.unsecureUnarchivedObject(ofClass: NSAttributedString.self, from: data)
            return attributedString
        }
        catch {
            assertionFailure("Failed to transform Data to MidomiTrack")
            return nil
        }
        
    }
}
