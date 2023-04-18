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
    
    private enum ModuleType {
        case playerEnters
        case addNewModule
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
        return collectionView
    }()
    
    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemType>(collectionView: self.collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
        self?.cell(for: indexPath, itemIdentifier: itemIdentifier)
    }
    
    private let levelSettingsCellRegistration = UICollectionView.CellRegistration<LevelSettingCollectionViewCell, ItemType> {_, _, _ in }
    private let playerEntersCellRegistration = UICollectionView.CellRegistration<PlayerEntersCollectionViewCell, ItemType> {_, _, _ in }
    private let addModuleCellRegistration = UICollectionView.CellRegistration<AddModuleCollectionViewCell, ItemType> {_, _, _ in }

    private let levelsViewModel = Levels.ViewModel(levels: 2)
    private var selectedLevel: Int = 0
    
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
}

extension GameCreatorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let snapshot = self.collectionViewDataSource.snapshot()
        guard snapshot.sectionIdentifiers[indexPath.section] == .modules else { return false }
        
        let itemIdentifier = snapshot.itemIdentifiers(inSection: .modules)
        if case let .module(type) = itemIdentifier[indexPath.row], type != .playerEnters {
            return true
        }
        return false
    }
}
