//
//  TextModuleCollectionViewCell.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/23/23.
//

import UIKit
import SwiftUI

final class TextModuleCollectionViewCell: SwiftUIHostingCollectionViewCell<TextModuleCollectionViewCell.CellContent> {
    private lazy var textView = {
        let textView = UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = Asset.Colors.Grayscale._10.color
        textView.font = .systemFont(ofSize: 14)
        let view = UIHostingController(rootView: InputAccessoryView() { [weak self] in
            self?.saveButtonTapped()
        }).view!
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
    
    var textModule: TextModule! {
        didSet {
            let attribString = NSMutableAttributedString(string: (textModule.character?.name ?? "") + ": ", attributes: [.foregroundColor : Asset.Colors.Grayscale._10.color])
            attribString.append(textModule.text ?? NSAttributedString())
            textView.attributedText = attribString
        }
    }
    
    private func saveButtonTapped() {
        var attribString = AttributedString(textView.attributedText)
        if let range = attribString.range(of: textModule.character!.name! + ": ") {
            attribString.replaceSubrange(range, with: AttributedString())
        }
        textModule.text = NSAttributedString(attribString)
        do {
            try textModule.managedObjectContext?.save()
        }
        catch {
            preconditionFailure("Failed to save text module text")
        }
    }
    
    struct CellContent: View {
        var body: some View {
            GeometryReader { _ in
                
            }
        }
    }
    
    fileprivate struct InputAccessoryView: View {
        let saveButtonTapped: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                Asset.Colors.Grayscale._70.swiftUIColor
                    .frame(height: 1)
                
                ScrollView {
                    HStack(spacing: 0) {
                        ButtonWithRoundedCornerBackground(cornerRadius: 15, backgroundColor: .clear, borderColor: Asset.Colors.Grayscale._70.swiftUIColor, selectedStatebackgroundColor: Asset.Colors.primary.swiftUIColor, selectedStateBorderColor: Asset.Colors.primary.swiftUIColor, isSelected: .constant(true)) {
                            
                        } content: {
                            Text("Narrator")
                                .font(.system(size: 12))
                                .foregroundColor(Asset.Colors.secondary.swiftUIColor)
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
                    
                    Button(action: saveButtonTapped) {
                        Text("Save")
                            .foregroundColor(Asset.Colors.secondary.swiftUIColor)
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 87, height: 34)
                    }
                    .background(Asset.Colors.primary.swiftUIColor)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 10)
                .padding(.top, 5)
                .padding(.bottom, 5)
            }
            .background(Asset.Colors.Grayscale._90.swiftUIColor)
        }
    }
}
