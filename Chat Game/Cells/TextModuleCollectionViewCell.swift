//
//  TextModuleCollectionViewCell.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/23/23.
//

import UIKit
import SwiftUI

final class TextModuleCollectionViewCell: SwiftUIHostingCollectionViewCell<TextModuleCollectionViewCell.CellContent> {
    private let textView = {
        let textView = UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .grayscale_10
        textView.font = .systemFont(ofSize: 14)
        let view = UIHostingController(rootView: InputAccessoryView()).view!
        view.bounds.size.height = view.intrinsicContentSize.height
        view.backgroundColor = .clear
        textView.inputAccessoryView = view
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSelectable = true
        self.isSelected = true
        
        self.swiftUIContentView = CellContent()

        self.contentView.addSubview(textView)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-33-[textView]-30-|", metrics: nil, views: ["textView" : textView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[textView]-16-|", metrics: nil, views: ["textView" : textView]))
        self.contentView.addConstraint(textView.heightAnchor.constraint(equalToConstant: 100))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var text: NSAttributedString? {
        get {
            textView.attributedText
        }
        
        set {
            textView.attributedText = newValue
        }
    }
    
    struct CellContent: View {
        var body: some View {
            GeometryReader { _ in
                
            }
        }
    }
    
    fileprivate struct InputAccessoryView: View {
        var body: some View {
            VStack(spacing: 0) {
                Color.grayscale_70
                    .frame(height: 1)
                
                ScrollView {
                    HStack(spacing: 0) {
                        ButtonWithRoundedCornerBackground(cornerRadius: 15, backgroundColor: .clear, borderColor: .grayscale_70, selectedStatebackgroundColor: .primary, selectedStateBorderColor: .primary, isSelected: .constant(true)) {
                            
                        } content: {
                            Text("Narrator")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                        }
                        .frame(height: 30)
                        
                        Spacer()
                    }
                    .padding(.leading, 16)
                }
                .padding(.top, 14)
                
                HStack(spacing: 0) {
                    Button {
                        
                    } label: {
                        Image(systemName: "italic")
                            .renderingMode(.template)
                            .foregroundColor(Color(hex: "#AFAEAD")!)
                    }
                    .frame(width: 30, height: 30)

                    Button {
                        
                    } label: {
                        Image(systemName: "bold")
                            .renderingMode(.template)
                            .foregroundColor(Color(hex: "#AFAEAD")!)
                    }
                    .frame(width: 30, height: 30)

                    Button {
                        
                    } label: {
                        Image(systemName: "underline")
                            .renderingMode(.template)
                            .foregroundColor(Color(hex: "#AFAEAD")!)
                    }
                    .frame(width: 30, height: 30)

                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Save")
                            .foregroundColor(.secondary)
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 87, height: 34)
                    }
                    .background(Color.primary)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                .padding(.top, 5)
                .padding(.bottom, 5)
            }
            .background(Color.grayscale_90)
        }
    }
}
