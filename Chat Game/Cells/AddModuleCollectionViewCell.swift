//
//  AddModuleCollectionViewCell.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/16/23.
//

import UIKit
import SwiftUI
import Combine

final class AddModuleCollectionViewCell: SwiftUIHostingCollectionViewCell<AddModuleCollectionViewCell.CellContent> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSelectable = true
        
        self.swiftUIContentView = CellContent(cell: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct CellContent: View {
        @ObservedObject var cell: AddModuleCollectionViewCell

        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                
                Image(systemName: "plus")
                    .padding(.trailing, 12)
                    .foregroundColor(Asset.Colors.primary.swiftUIColor)
                
                Text("Add Module")
                    .foregroundColor(cell.hasBeenSelected ? Asset.Colors.primary.swiftUIColor : Asset.Colors.Grayscale._40.swiftUIColor)
                    .font(.system(size: 14))
                
                Spacer()
            }
            .frame(height: 65)
        }
    }
}
