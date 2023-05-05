//
//  TextModule+CoreDataProperties.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 5/5/23.
//
//

import Foundation
import CoreData
import UIKit

extension TextModule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TextModule> {
        return NSFetchRequest<TextModule>(entityName: "TextModule")
    }

    @NSManaged public var text: NSAttributedString?
    @NSManaged public var images: [UIImage]?
    @NSManaged public var character: Character?

}
