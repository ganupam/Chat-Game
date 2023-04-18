//
//  SwiftUIHostingCollectionViewCell.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/18/23.
//

import UIKit
import SwiftUI

class SwiftUIHostingCollectionViewCell<Content: View>: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var swiftUIContentView: Content? {
        didSet {
            guard let content = swiftUIContentView else {
                self.contentView.viewWithTag(1)?.removeFromSuperview()
                return
            }
            
            let vc = UIHostingController(rootView: content)
            vc.view.backgroundColor = .clear
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.tag = 1
            self.contentView.addSubview(vc.view)
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", metrics: nil, views: ["view" : vc.view as Any]))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", metrics: nil, views: ["view" : vc.view as Any]))
        }
    }
}
