//
//  SwiftUIHostingCollectionViewCell.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/18/23.
//

import UIKit
import SwiftUI

protocol SelectableCollectionViewCell where Self: UICollectionViewCell {
    var isSelectable: Bool { get set }
    var hasBeenSelected: Bool { get set }
}

class SwiftUIHostingCollectionViewCell<Content: View>: UICollectionViewCell, SelectableCollectionViewCell, ObservableObject {
    @Published var isSelectable = false
    @Published var hasBeenSelected = false
    var cellHeightChanged: (() -> Void)?
    private(set) var swiftUIContentViewController: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var swiftUIContentView: Content? {
        didSet {
            self.contentView.viewWithTag(1)?.removeFromSuperview()
            
            guard let content = swiftUIContentView else {
                return
            }
            
            let vc = UIHostingController(rootView: CellContent(cell: self) {
                content
            })
            vc.view.backgroundColor = .clear
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.tag = 1
            self.contentView.addSubview(vc.view)
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", metrics: nil, views: ["view" : vc.view as Any]))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", metrics: nil, views: ["view" : vc.view as Any]))
            self.swiftUIContentViewController = vc
        }
    }
    
    private struct CellContent<Content: View>: View {
        @ObservedObject var cell: SwiftUIHostingCollectionViewCell
        @ViewBuilder var content: () -> Content
        
        var body: some View {
            if cell.isSelectable {
                SelectableCellContent(isSelected: $cell.hasBeenSelected) {
                    content()
                }
                .padding(.horizontal, 16)
            } else {
                content()
            }
        }
    }
}
