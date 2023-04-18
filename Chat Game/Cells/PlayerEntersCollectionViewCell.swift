//
//  PlayerEntersCollectionViewCell.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/16/23.
//

import UIKit
import SwiftUI

final class PlayerEntersCollectionViewCell: SwiftUIHostingCollectionViewCell<PlayerEntersCollectionViewCell.CellContent> {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.swiftUIContentView = CellContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct CellContent: View {
        private let text = {
            let attributedText = NSMutableAttributedString(string: "Player: ", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: "#5EE31F") as Any])
            attributedText.append(NSMutableAttributedString(string: "Enters the level", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white]))
            return attributedText
        }()
        
        var body: some View {
            ViewWithRoundedCornerBackground(cornerRadius: 7, backgroundColor: Color(.grayscale_80)) {
                HStack {
                    Text(AttributedString(text))
                        .font(.system(size: 14))
                        .padding(.leading, 16)
                    
                    Spacer()
                }
                .frame(height: 41)
            }
            .padding(.horizontal, 16)
        }
    }
}
