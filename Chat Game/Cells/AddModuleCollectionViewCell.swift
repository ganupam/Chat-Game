//
//  AddModuleCollectionViewCell.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/16/23.
//

import UIKit
import SwiftUI

final class AddModuleCollectionViewCell: SwiftUIHostingCollectionViewCell<AddModuleCollectionViewCell.CellContent> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.swiftUIContentView = CellContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct CellContent: View {
        var body: some View {
            ViewWithRoundedCornerBackground(cornerRadius: 7, backgroundColor: Color(.grayscale_90), borderColor: Color(UIColor(hex: "#404040")!)) {
                HStack(spacing: 0) {
                    Spacer()
                    
                    Image(systemName: "plus")
                        .padding(.trailing, 12)
                        .foregroundColor(Color(.primary))
                    
                    Text("Add Module")
                        .foregroundColor(Color(.grayscale_40))
                        .font(.system(size: 14))
                    
                    Spacer()
                }
                .frame(height: 65)
            }
            .padding(.horizontal, 16)
        }
    }
}
