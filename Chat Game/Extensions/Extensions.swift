//
//  Extensions.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/11/23.
//

import Foundation
import UIKit
import SwiftUI

//private enum Path: String {
//    case colors
//    case grayscale
//    case utility
//}

extension UIColor {
//    fileprivate convenience init?(paths: [Path], colorName: String) {
//        var path = (paths.reduce("") { partialResult, partialPath in
//            partialResult + (!partialResult.isEmpty ? "/" : "") + partialPath.rawValue
//        })
//        path +=  (!path.isEmpty ? "/" : "") + colorName
//        self.init(named: path)
//    }
//
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        guard hex.hasPrefix("#") else { return nil }
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
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
//
//    static let grayscale_40 = UIColor(paths: [Path.colors, Path.grayscale], colorName: "40")!
//    static let grayscale_90 = UIColor(paths: [Path.colors, Path.grayscale], colorName: "90")!
//    static let grayscale_80 = UIColor(paths: [Path.colors, Path.grayscale], colorName: "80")!
//    static let grayscale_70 = UIColor(paths: [Path.colors, Path.grayscale], colorName: "70")!
//    static let grayscale_60 = UIColor(paths: [Path.colors, Path.grayscale], colorName: "60")!
//    static let grayscale_10 = UIColor(paths: [Path.colors, Path.grayscale], colorName: "10")!
//    static let grayscale_20 = UIColor(paths: [Path.colors, Path.grayscale], colorName: "20")!
//    static let header_background = UIColor(paths: [Path.colors, Path.utility], colorName: "header_background")!
//    static let primary = UIColor(paths: [Path.colors], colorName: "primary")!
//    static let secondary = UIColor(paths: [Path.colors], colorName: "secondary")!
}

extension Color {
//    static let grayscale_40 = Color(uiColor: UIColor(paths: [Path.colors, Path.grayscale], colorName: "40")!)
//    static let grayscale_90 = Color(UIColor(paths: [Path.colors, Path.grayscale], colorName: "90")!)
//    static let grayscale_80 = Color(UIColor(paths: [Path.colors, Path.grayscale], colorName: "80")!)
//    static let grayscale_70 = Color(UIColor(paths: [Path.colors, Path.grayscale], colorName: "70")!)
//    static let grayscale_10 = Color(UIColor(paths: [Path.colors, Path.grayscale], colorName: "10")!)
//    static let grayscale_20 = Color(UIColor(paths: [Path.colors, Path.grayscale], colorName: "20")!)
//    static let header_background = Color(UIColor(paths: [Path.colors, Path.utility], colorName: "header_background")!)
//    static let primary = Color(UIColor(paths: [Path.colors], colorName: "primary")!)
//    static let secondary = Color(UIColor(paths: [Path.colors], colorName: "secondary")!)
//    static let grayscale_60 = Color(UIColor(paths: [Path.colors, Path.grayscale], colorName: "60")!)

    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        
        self.init(uiColor: uiColor)
    }
}
