//
//  GameCreatorViewController.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/11/23.
//

import UIKit
import SwiftUI
import Combine
import UniformTypeIdentifiers

final class GameCreatorViewController: BaseViewController {
    private enum SectionIdentifier: Hashable {
        case levelSettings
        case modules
    }
    
    private enum ItemType: Hashable {
        case levelSettingBackground
        case levelSettingMusic
        case module(ModuleType)
    }
    
    private enum ModuleType: Hashable {
        case playerEnters
        case addNewModule
        case text(UUID, TextModuleModel)
    }
    
    private struct TextModuleModel: Hashable {
        let text: NSAttributedString?
    }
    
    private let backgroundImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.alpha = 0.2
        return backgroundImageView
    }()
        
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { [weak self] index, environment in
            self?.section(for: index)
        }))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDragWithAccessory
        return collectionView
    }()
    
    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemType>(collectionView: self.collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
        self?.cell(for: indexPath, itemIdentifier: itemIdentifier)
    }
    
    private let levelSettingsCellRegistration = UICollectionView.CellRegistration<LevelSettingCollectionViewCell, ItemType> {_, _, _ in }
    private let playerEntersCellRegistration = UICollectionView.CellRegistration<PlayerEntersCollectionViewCell, ItemType> {_, _, _ in }
    private let addModuleCellRegistration = UICollectionView.CellRegistration<AddModuleCollectionViewCell, ItemType> {_, _, _ in }
    private let textModuleCellRegistration = UICollectionView.CellRegistration<TextModuleCollectionViewCell, ItemType> {_, _, _ in }

    private let levelsViewModel = Levels.ViewModel(levels: 2)
    private var selectedLevel: Int = 0
    private var selectedModule: ItemType?
    private lazy var addModuleToolbar = {
        let toolbar = UIHostingController(rootView: AddModuleToolbar() { [weak self] in
            self?.toolbarButtonTapped($0)
        })
        toolbar.view.translatesAutoresizingMaskIntoConstraints = false
        toolbar.view.alpha = 0
        toolbar.view.backgroundColor = .clear
        return toolbar.view!
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "Create", image: UIImage(named: "create_game_tab"), selectedImage: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.title = "Create"
        
        let vc = UIHostingController(rootView: Levels(selectedLevel: Binding(get: {
            self.selectedLevel
        }, set: {
            self.selectedLevel = $0
        }), vm: levelsViewModel))
        self.view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.backgroundColor = .clear

        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.collectionView)

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", metrics: nil, views: ["backgroundImageView" : self.backgroundImageView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", metrics: nil, views: ["backgroundImageView" : self.backgroundImageView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[levelsView]|", metrics: nil, views: ["levelsView" : vc.view!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", metrics: nil, views: ["collectionView" : self.collectionView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-19-[levelsView(==29)]-19-[collectionView]|", metrics: nil, views: ["levelsView" : vc.view!, "collectionView" : self.collectionView]))
        
        self.view.addSubview(self.addModuleToolbar)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[toolbar]-20-|", metrics: nil, views: ["toolbar" : self.addModuleToolbar as Any]))
        self.view.addConstraints([
            self.addModuleToolbar.heightAnchor.constraint(equalToConstant: 54),
            self.addModuleToolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        ])

        self.loadDataSource()
    }
    
    private func loadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemType>()
        snapshot.appendSections([.levelSettings, .modules])
        snapshot.appendItems([.levelSettingBackground, .levelSettingMusic], toSection: .levelSettings)
        snapshot.appendItems([.module(.playerEnters), .module(.addNewModule)], toSection: .modules)
        self.collectionViewDataSource.apply(snapshot)
    }
    
    private func cell(for indexPath: IndexPath, itemIdentifier: ItemType) -> UICollectionViewCell {
        switch itemIdentifier {
        case .levelSettingBackground:
            let cell = self.collectionView.dequeueConfiguredReusableCell(using: levelSettingsCellRegistration, for: indexPath, item: itemIdentifier)
            cell.title = "Level Background"
            cell.image = UIImage(named: "level_background_image")
            cell.buttonTapped = { [weak self] in
                self?.levelSettingBackgroundButtonTapped()
            }
            return cell
            
        case .levelSettingMusic:
            let cell = self.collectionView.dequeueConfiguredReusableCell(using: levelSettingsCellRegistration, for: indexPath, item: itemIdentifier)
            cell.title = "Level Music"
            cell.image = UIImage(named: "level_background_image")
            cell.buttonTapped = { [weak self] in
                self?.levelSettingMusicButtonTapped()
            }
            return cell
            
        case .module(let type):
            switch type {
            case .playerEnters:
                return self.collectionView.dequeueConfiguredReusableCell(using: playerEntersCellRegistration, for: indexPath, item: itemIdentifier)
                
            case .addNewModule:
                return self.collectionView.dequeueConfiguredReusableCell(using: addModuleCellRegistration, for: indexPath, item: itemIdentifier)
                
            case .text(_, let model):
                let cell = self.collectionView.dequeueConfiguredReusableCell(using: textModuleCellRegistration, for: indexPath, item: itemIdentifier)
                cell.text = model.text
                return cell
            }
        }
    }
    
    private func section(for index: Int) -> NSCollectionLayoutSection? {
        guard let sectionIdentifier = self.collectionViewDataSource.sectionIdentifier(for: index) else { return nil }
        switch sectionIdentifier {
        case .levelSettings:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), subitem: item, count: 2)
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(16)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
            return section

        case .modules:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)), subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = .init(top: 17, leading: 0, bottom: 0, trailing: 0)
            return section
        }
    }
    
    private func levelSettingBackgroundButtonTapped() {
        ImageVideoPicker.presentImagePicker(on: self) {
            guard let result = $0.first?.itemProvider, result.canLoadObject(ofClass: UIImage.self) else { return }
            
            result.loadObject(ofClass: UIImage.self) { image, error in
                guard let image = image as? UIImage, error == nil else { return }
                
                DispatchQueue.main.async {
                    self.backgroundImageView.image = image
                }
            }
        }
    }
    
    private func levelSettingMusicButtonTapped() {
        
    }
    
    private func toolbarButtonTapped(_ buttonType: AddModuleToolbar.ToolbarButton) {
        if buttonType == .text {
            let newTextModuleType = ItemType.module(.text(UUID(), TextModuleModel(text: NSAttributedString(string: "Narrator: ", attributes: [.foregroundColor : UIColor.grayscale_10]))))
            self.selectedModule = newTextModuleType
            self.showHideToolbar()
            
            var snapshot = self.collectionViewDataSource.snapshot()
            snapshot.deleteItems([.module(.addNewModule)])
            snapshot.appendItems([newTextModuleType], toSection: .modules)
            self.collectionViewDataSource.apply(snapshot) {
                guard let indexPath = self.collectionViewDataSource.indexPath(for: newTextModuleType),
                      let cell = self.collectionView.cellForItem(at: indexPath) as? TextModuleCollectionViewCell else { return }
                
                cell.hasBeenSelected = true
            }
        }
    }
}

extension GameCreatorViewController {
    private struct Levels: View {
        final class ViewModel: ObservableObject {
            @Published var levels: Int
            
            init(levels: Int) {
                self.levels = levels
            }
        }

        @Binding var selectedLevel: Int
        @State private var levelSelected = 0
        @ObservedObject private(set) var vm: ViewModel

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(0 ..< vm.levels, id: \.self) { index in
                        Button {
                            withAnimation(.linear(duration: 0.1)) {
                                levelSelected = index
                            }
                            selectedLevel = index
                        } label: {
                            Text("level \(index + 1)")
                                .font(.system(size: 11))
                                .foregroundColor(Color(.grayscale_10))
                        }
                        .frame(width: 66)
                        .background(Image(levelSelected == index ? "level_selected" : "level_unselected"))
                    }
                    
                    ButtonWithRoundedCornerBackground(cornerRadius: 5, backgroundColor: Color(UIColor(hex: "#262522")!), borderColor: Color(UIColor(hex: "#262522")!), selectedStatebackgroundColor: .white, selectedStateBorderColor: .white, isSelected: .constant(false)) {
                        
                    } content: {
                        Image("add_level")
                            .frame(width: 66)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
    }
    
    private struct AddModuleToolbar: View {
        enum ToolbarButton {
            case add
            case text
            case image
            case video
            case gameController
            case condition
        }
        
        let toolbarButtonTapped: (ToolbarButton) -> Void
        
        var body: some View {
            ViewWithRoundedCornerBackground(cornerRadius: 54 / 2, backgroundColor: Color(UIColor(hex: "#343434")!)) {
                VStack(spacing: 0) {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Button {
                                toolbarButtonTapped(.add)
                            } label: {
                                Image("module_add")
                            }
                            .disabled(true)
                            
                            Spacer()
                            Button {
                                toolbarButtonTapped(.text)
                            } label: {
                                Image("module_text")
                            }
                            
                            Spacer()
                            Button {
                                toolbarButtonTapped(.image)
                            } label: {
                                Image("module_image")
                            }
                        }
                        .padding(.leading, 13)
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            Button {
                                toolbarButtonTapped(.video)
                            } label: {
                                Image("module_video")
                            }
                            .padding(.leading, 13)
                            
                            Spacer()
                            Button {
                                toolbarButtonTapped(.gameController)
                            } label: {
                                Image("module_game_controller")
                            }
                            
                            Spacer()
                            Button {
                                toolbarButtonTapped(.condition)
                            } label: {
                                Image("module_condition")
                            }
                        }
                        .padding(.trailing, 13)
                    }

                    Spacer()
                }
            }
        }
    }
}

extension GameCreatorViewController: UICollectionViewDelegate {
    private func itemIdentifier(from indexPath: IndexPath) -> ItemType? {
        let snapshot = self.collectionViewDataSource.snapshot()
        guard snapshot.sectionIdentifiers[indexPath.section] == .modules else { return nil }
        let itemIdentifiers = snapshot.itemIdentifiers(inSection: .modules)
        return (indexPath.row < itemIdentifiers.count ? itemIdentifiers[indexPath.row] : nil)
    }
    
    private func canSelectDeselect(_ indexPath: IndexPath) -> Bool {
        guard let itemIdentifier = self.itemIdentifier(from: indexPath) else { return false }
        
        if case let .module(type) = itemIdentifier, type != .playerEnters {
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AddModuleCollectionViewCell else { return }
        
        if self.itemIdentifier(from: indexPath) == self.selectedModule {
            cell.hasBeenSelected = false
            self.selectedModule = nil
        } else {
            cell.hasBeenSelected = true
            self.selectedModule = self.itemIdentifier(from: indexPath)
        }
        
        self.showHideToolbar()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        canSelectDeselect(indexPath)
    }
    
    private func showHideToolbar() {
        var alpha = 0.0
        if case let .module(type) = self.selectedModule, type == .addNewModule {
            alpha = 1
        }

        UIView.animate(withDuration: 0.15) {
            self.addModuleToolbar.alpha = alpha
        }
    }
}
