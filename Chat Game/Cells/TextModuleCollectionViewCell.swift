//
//  TextModuleCollectionViewCell.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/23/23.
//

import UIKit
import SwiftUI
import Combine

final class TextModuleCollectionViewCell: SwiftUIHostingCollectionViewCell<TextModuleCollectionViewCell.CellContent> {
    private lazy var textView = {
        let textView = UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = Asset.Colors.Grayscale._10.color
        textView.font = .systemFont(ofSize: 14)
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.delegate = self
        return textView
    }()

    private var imagesVC: UIHostingController<Images>?
    
    override var hasBeenSelected: Bool {
        didSet {
            self.textView.isUserInteractionEnabled = self.hasBeenSelected
        }
    }
    
    var presentingViewController: UIViewController!
    
    private var notificationToken: NotificationToken?
    private var characterChangeKVO, imagesChangedKVO: NSKeyValueObservation?
    private var currentTextViewHeight: CGFloat = 0
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSelectable = true
        self.isSelected = true
        
        self.swiftUIContentView = CellContent()
        
        self.contentView.addSubview(textView)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-33-[textView]-30-|", metrics: nil, views: ["textView" : textView]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[textView]", metrics: nil, views: ["textView" : textView]))
        self.textView.setContentHuggingPriority(.required, for: .vertical)
        self.textView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.textViewHeightConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var textModule: TextModule! {
        didSet {
            guard textModule !== oldValue else { return }
            
            self.createImagesVC()
            
            let attribString = NSMutableAttributedString(string: (textModule.character?.name ?? "") + ": ", attributes: [.foregroundColor : Asset.Colors.Grayscale._10.color])
            attribString.append(textModule.text ?? NSAttributedString())
            textView.attributedText = attribString
            
            let rootView = InputAccessoryView(game: self.textModule.level!.game!, textModule: self.textModule) { [weak self] character in
                self?.textModule.character = character
                try? self?.textModule.managedObjectContext?.save()
            } addCharacterTapped: { [weak self] in
                self?.addCharacterTapped()
            } addImageTapped: { [weak self] in
                self?.addImageTapped()
            } saveButtonTapped: { [weak self] in
                self?.saveButtonTapped()
            }
                .environment(\.managedObjectContext, textModule.managedObjectContext!)
            
            let view = UIHostingController(rootView: rootView).view!
            view.bounds.size.height = view.intrinsicContentSize.height
            view.backgroundColor = .clear
            textView.inputAccessoryView = view
            
            self.textViewHeightConstraint.isActive = self.textModule.images?.isEmpty ?? true

            self.characterChangeKVO = textModule.observe(\.character, options: [.old, .new]) { [weak self] _, change in
                guard let self else { return }
                
                let attribString = self.textView.attributedText.mutableCopy() as? NSMutableAttributedString
                if let oldValue = change.oldValue, let oldCharacter = oldValue {
                    let replacementText = oldCharacter.name ?? ""
                    attribString?.mutableString.replaceOccurrences(of: replacementText, with: change.newValue??.name ?? "", range: NSRange(location: 0, length: attribString?.length ?? 0))
                } else {
                    attribString?.mutableString.insert((change.newValue??.name ?? "") + ": ", at: 0)
                }
                
                self.textView.attributedText = attribString
            }
            
            self.imagesChangedKVO = textModule.observe(\.images, options: .new) { [weak self] _, changes in
                self?.textViewHeightConstraint.isActive = (self?.textModule.images?.isEmpty ?? true)
            }
        }
    }
    
    private func createImagesVC() {
        let rootView = Images(cell: self, textModule: self.textModule, cellHeightChanged: { [weak self] in
            self?.imagesVC?.view.invalidateIntrinsicContentSize()
            self?.cellHeightChanged?()
        }, deleteImageTapped: { [weak self] in
            self?.deleteImageTapped($0)
        })
        
        if self.imagesVC == nil {
            let vc = UIHostingController(rootView: rootView)
            if #available(iOS 16.0, *) {
                vc.sizingOptions = [.intrinsicContentSize]
            }
            self.imagesVC = vc

            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.backgroundColor = .clear
            self.contentView.addSubview(vc.view)
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-33-[images]-30-|", metrics: nil, views: ["images" : vc.view!]))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textView][images]-16-|", metrics: nil, views: ["textView" : self.textView, "images" : vc.view!]))
        } else {
            self.imagesVC?.rootView = rootView
        }
    }
    
    private func addImageTapped() {
        ImageVideoPicker.presentImagePicker(on: self.presentingViewController, allowMultipleSelection: true, completionHandler: {
            for result in $0 where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage, error == nil else { return }
                    
                    DispatchQueue.main.async {
                        var images = self.textModule.images ?? []
                        images.append(image)
                        self.textModule.images = images
                        do {
                            try self.textModule.managedObjectContext?.save()
                        }
                        catch {
                            preconditionFailure("Failed to add image")
                        }
                    }
                }
            }
        })
    }
    
    private func deleteImageTapped(_ image: UIImage) {
        self.textModule.images?.removeAll {
            $0 == image
        }
        do {
            try self.textModule.managedObjectContext?.save()
        }
        catch {
            preconditionFailure("Failed to add image")
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
        
        textView.resignFirstResponder()
    }
    
    private func addCharacterTapped() {
        let alert = UIAlertController(title: "Character name", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alert, weak self] _ in
            let title = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
            self?.createCharacter(with: title)
        }
        confirmAction.isEnabled = false
        alert.addAction(confirmAction)
        alert.addTextField {
            $0.autocapitalizationType = .words
        }
        self.presentingViewController.present(alert, animated: true)
        self.notificationToken = NotificationCenter.default.addTokenizedObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?.first, queue: .main) { _ in
            confirmAction.isEnabled = !(alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        }
    }
    
    private func createCharacter(with name: String) {
        guard DataManager.shared.character(with: name, game: textModule.level!.game!) == nil else {
            let alert = UIAlertController(title: "Character named \(name) exists already.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.presentingViewController.present(alert, animated: true)
            return
        }
        
        let character = DataManager.shared.createCharacter(with: name, game: textModule.level!.game!)
        textModule.character = character
        try? textModule.managedObjectContext?.save()
    }
    
    struct CellContent: View {
        var body: some View {
            GeometryReader { _ in
                
            }
        }
    }
    
    fileprivate struct InputAccessoryView: View {
        @ObservedObject var game: Game
        @ObservedObject var textModule: TextModule
        let selectedCharacterChanged: (Character) -> Void
        let addCharacterTapped: () -> Void
        let addImageTapped: () -> Void
        let saveButtonTapped: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                Asset.Colors.Grayscale._70.swiftUIColor
                    .frame(height: 1)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach((game.characters?.array as? [Character]) ?? []) { character in
                            ButtonWithRoundedCornerBackground(cornerRadius: 15, backgroundColor: .clear, borderColor: Asset.Colors.Grayscale._70.swiftUIColor, selectedStatebackgroundColor: Asset.Colors.primary.swiftUIColor, selectedStateBorderColor: Asset.Colors.primary.swiftUIColor, isSelected: .constant(textModule.character == character)) {
                                selectedCharacterChanged(character)
                            } content: {
                                Text(character.name ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(textModule.character == character ? Asset.Colors.secondary.swiftUIColor : Asset.Colors.Grayscale._10.swiftUIColor.opacity(0.56))
                                    .padding(.horizontal, 10)
                            }
                            .frame(height: 30)
                        }
                        
                        ButtonWithRoundedCornerBackground(cornerRadius: 15, backgroundColor: .clear, borderColor: Asset.Colors.Grayscale._70.swiftUIColor, selectedStatebackgroundColor: Asset.Colors.Grayscale._70.swiftUIColor, isSelected: .constant(false), action: addCharacterTapped) {
                            Text("+ Add Character")
                                .font(.system(size: 13))
                                .foregroundColor(Asset.Colors.Grayscale._10.swiftUIColor.opacity(0.56))
                                .padding(.horizontal, 10)
                        }
                        .frame(height: 30)
                        
                        Spacer()
                    }
                    .padding(.leading, 16)
                }
                .padding(.top, 14)
                
                HStack(spacing: 0) {
                    Button(action: addImageTapped) {
                        Image("add_text_image")
                            .renderingMode(.template)
                            .foregroundColor(Color(hex: "#AFAEAD")!)
                    }
                    .frame(width: 30, height: 30)
                    
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

extension TextModuleCollectionViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.cellHeightChanged?()
    }
}

private extension TextModuleCollectionViewCell {
    struct Images: View {
        @ObservedObject var cell: TextModuleCollectionViewCell
        @ObservedObject var textModule: TextModule
        let cellHeightChanged: () -> Void
        let deleteImageTapped: (UIImage) -> Void
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(textModule.images ?? [], id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 75, height: 75)
                                .cornerRadius(5)
                            
                            if cell.hasBeenSelected {
                                Button {
                                    deleteImageTapped(image)
                                } label: {
                                    Image(asset: Asset.Images.deleteTextModuleImage)
                                }
                                .offset(x: 11, y: -11)
                            }
                        }
                        .animation(Animation.linear(duration: 0.1), value: cell.hasBeenSelected)
                    }
                }
                .animation(Animation.linear(duration: 0.1), value: textModule.images)
                .padding(.top, 11)
            }
            .onChange(of: textModule.images) { _ in
                cellHeightChanged()
            }
        }
    }
}
