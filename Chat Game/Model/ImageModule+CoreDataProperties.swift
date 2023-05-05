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
    @objc public enum Size: Int16 {
        case small
        case medium
        case large
    }

    @objc public enum Alignment: Int16 {
        case left
        case center
        case right
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageModule> {
        return NSFetchRequest<ImageModule>(entityName: "ImageModule")
    }

    @NSManaged public var image: UIImage?
    @NSManaged public var size: Size
    @NSManaged public var alignment: Alignment
}
