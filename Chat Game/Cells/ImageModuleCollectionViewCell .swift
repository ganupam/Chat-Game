//
//  ImageModuleCollectionViewCell.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/16/23.
//

import UIKit
import SwiftUI
import Combine

final class ImageModuleCollectionViewCell: SwiftUIHostingCollectionViewCell<ImageModuleCollectionViewCell.CellContent> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isSelectable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageModule: ImageModule! {
        didSet {
            self.swiftUIContentView = CellContent(imageModule: self.imageModule) {
                self.swiftUIContentViewController?.view.invalidateIntrinsicContentSize()
                self.cellHeightChanged?()
            }
        }
    }
    
    struct CellContent: View {
        @ObservedObject var imageModule: ImageModule
        let cellHeightChanged: () -> Void
        
        var imageWidthHeight: CGFloat {
            switch imageModule.size {
            case .small:
                return 75
                
            case .medium:
                return 135
                
            case .large:
                return 200
            }
        }
        
        var body: some View {
            HStack(spacing: 0) {
                if imageModule.alignment != .left {
                    Spacer()
                }
                
                Image(uiImage: imageModule.image!)
                    .resizable()
                    .frame(width: imageWidthHeight, height: imageWidthHeight)
                    .cornerRadius(4)

                if imageModule.alignment != .right {
                    Spacer()
                }
            }
            .padding(.vertical, 13)
            .onChange(of: imageModule.size) { _ in
                cellHeightChanged()
            }
        }
    }
}
