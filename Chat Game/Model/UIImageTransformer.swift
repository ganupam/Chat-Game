//
//  UIImageTransformer.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/27/23.
//

import UIKit

@objc(UIImageTransformer)
final class UIImageTransformer: ValueTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: UIImageTransformer.self))
    
    static func register() {
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: Self.name)
    }
    
    override class func transformedValueClass() -> AnyClass {
        UIImage.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let image = value as? UIImage, let imageData = image.jpegData(compressionQuality: 1) else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: imageData, requiringSecureCoding: false)
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
            if let imageData = try NSKeyedUnarchiver.unsecureUnarchivedObject(ofClass: NSData.self, from: data) {
                return UIImage(data: imageData as Data)
            }
        }
        catch {
            assertionFailure("Failed to transform Data to MidomiTrack")
        }
        return nil
    }
}
