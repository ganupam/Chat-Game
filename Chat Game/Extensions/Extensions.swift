//
//  Extensions.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/11/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        let hexColor: String
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            hexColor = String(hex[start...])
        } else {
            hexColor = hex
        }
        
        guard hexColor.count == 8 || hexColor.count == 6 else { return nil }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        if hexColor.count == 8 {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        } else {
            r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x000000ff) / 255
            a = 1
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Color {
    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        
        self.init(uiColor: uiColor)
    }
}

final class NotificationToken: NSObject {
    private let token: Any

    init(token: Any) {
        self.token = token
    }

    deinit {
        NotificationCenter.default.removeObserver(token)
    }
    
    func store(in array: inout [NotificationToken]) {
        array.append(self)
    }
    
    func unregister() {
        NotificationCenter.default.removeObserver(token)
    }
}

extension NotificationCenter {
    /// NotificationCenter.addObserver(forName:object:queue:using:) doesn't unregister itself when the object is deallocated which cause the block to be leaked/not deallocated.
    @inline(__always) func addTokenizedObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NotificationToken {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(token: token)
    }
}

extension NSKeyedUnarchiver {
    static func unsecureUnarchivedObject<DecodedObjectType>(ofClass cls: DecodedObjectType.Type, from data: Data) throws -> DecodedObjectType? where DecodedObjectType : NSObject, DecodedObjectType : NSCoding {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            let object = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DecodedObjectType
            return object
        }
        catch {
            throw error
        }
    }
    
    static func unsecureUnarchivedObject<DecodedObjectType>(ofClass cls: DecodedObjectType.Type, from filename: String) throws -> DecodedObjectType? where DecodedObjectType : NSObject, DecodedObjectType : NSCoding {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filename))
            return try self.unsecureUnarchivedObject(ofClass: cls, from: data)
        }
        catch let error {
            throw error
        }
    }
}
