//
//  ImageModule+CoreDataProperties.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 5/5/23.
//
//

import Foundation
import CoreData
import UIKit

extension ImageModule {
    @objc public enum Size: Int16, CustomStringConvertible {
        case small
        case medium
        case large
        
        public var description: String {
            switch self {
            case .small:
                return "Small"
                
            case .medium:
                return "Medium"
                
            case .large:
                return "Large"
            }
        }
    }

    @objc public enum Alignment: Int16, CustomStringConvertible {
        case left
        case center
        case right
        
        public var description: String {
            switch self {
            case .left:
                return "Left"
                
            case .center:
                return "Center"
                
            case .right:
                return "Right"
            }
        }
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageModule> {
        return NSFetchRequest<ImageModule>(entityName: "ImageModule")
    }

    @NSManaged public var image: UIImage?
    @NSManaged public var size: Size
    @NSManaged public var alignment: Alignment
}
