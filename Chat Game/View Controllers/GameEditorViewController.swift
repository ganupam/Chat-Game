//
//  GameEditorViewController.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/11/23.
//

import UIKit
import SwiftUI
import Combine
import UniformTypeIdentifiers

final class GameEditorViewController: BaseViewController {
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
        case text(TextModule)
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
    
    private var notificationToken: NotificationToken?
    
    private let levelSettingsCellRegistration = UICollectionView.CellRegistration<LevelSettingCollectionViewCell, ItemType> {_, _, _ in }
    private let playerEntersCellRegistration = UICollectionView.CellRegistration<PlayerEntersCollectionViewCell, ItemType> {_, _, _ in }
    private let addModuleCellRegistration = UICollectionView.CellRegistration<AddModuleCollectionViewCell, ItemType> {_, _, _ in }
    private let textModuleCellRegistration = UICollectionView.CellRegistration<TextModuleCollectionViewCell, ItemType> {_, _, _ in }
    
    private var selectedLevel: Int = 0
    private var selectedModule: ItemType? {
        willSet {
            guard let selectedModule else { return }
            
            if let indexPath = self.collectionViewDataSource.indexPath(for: selectedModule),
               let cell = self.collectionView.cellForItem(at: indexPath) as? SelectableCollectionViewCell {
                cell.hasBeenSelected = false
            }
        }
        
        didSet {
            if let selectedModule, let indexPath = self.collectionViewDataSource.indexPath(for: selectedModule),
               let cell = self.collectionView.cellForItem(at: indexPath) as? SelectableCollectionViewCell {
                cell.hasBeenSelected = true
            }
        }
    }
    private lazy var addModuleToolbar = {
        let toolbar = UIHostingController(rootView: AddModuleToolbar() { [weak self] in
            self?.toolbarButtonTapped($0)
        })
        toolbar.view.translatesAutoresizingMaskIntoConstraints = false
        toolbar.view.alpha = 0
        toolbar.view.backgroundColor = .clear
        return toolbar.view!
    }()
    
    private lazy var createNewGameVC: UIHostingController<GameEditorViewController.CreateNewGame>? = UIHostingController(rootView: CreateNewGame() { [weak self] in
        self?.createNewGame()
    })
    
    private(set) var game: Game!
    
    init(game: Game?) {
        self.game = game
        
        super.init(nibName: nil, bundle: nil)
    }
    
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
        
        if self.game == nil {
            let vc = createNewGameVC!
            self.view.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.backgroundColor = .clear
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[createNewGameView]|", metrics: nil, views: ["createNewGameView" : vc.view!]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[createNewGameView]|", metrics: nil, views: ["createNewGameView" : vc.view!]))
        } else {
            self.initializeGameEditor()
        }
    }
    
    private func createNewGame() {
        let alert = UIAlertController(title: "Game title", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let confirmAction = UIAlertAction(title: "Create", style: .default) { [weak alert, weak self] _ in
            let title = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
            self?.game = DataManager.shared.createNewGame(title)
            self?.switchToGameEditorMode()
        }
        confirmAction.isEnabled = false
        alert.addAction(confirmAction)
        alert.addTextField {
            $0.autocapitalizationType = .words
        }
        self.present(alert, animated: true)
        self.notificationToken = NotificationCenter.default.addTokenizedObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?.first, queue: .main) { _ in
            confirmAction.isEnabled = !(alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        }
    }
    
    private func switchToGameEditorMode() {
        self.createNewGameVC?.view.removeFromSuperview()
        self.createNewGameVC = nil
        self.initializeGameEditor()
    }
    
    private func initializeGameEditor() {
        self.title = self.game.title
        self.tabBarItem = UITabBarItem(title: "Create", image: UIImage(named: "create_game_tab"), selectedImage: nil)

        let vc = UIHostingController(rootView: Levels(game: self.game, selectedLevel: Binding(get: {
            self.selectedLevel
        }, set: {
            self.selectedLevel = $0
            self.changeLevel(to: self.game.levels!.array[$0] as! Level)
        })))
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
        
        self.initializeDataSource()
    }
    
    private func initializeDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemType>()
        snapshot.appendSections([.levelSettings, .modules])
        snapshot.appendItems([.levelSettingBackground, .levelSettingMusic], toSection: .levelSettings)
        self.addModulesToDataSource(for: self.game.levels!.firstObject as! Level, snapshot: &snapshot)
        self.collectionViewDataSource.apply(snapshot)
    }
    
    private func changeLevel(to level: Level) {
        var snapshot = self.collectionViewDataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .modules))
        self.addModulesToDataSource(for: level, snapshot: &snapshot)
        self.collectionViewDataSource.apply(snapshot)
    }
    
    private func addModulesToDataSource(for level: Level, snapshot: inout NSDiffableDataSourceSnapshot<SectionIdentifier, ItemType>) {
        var modules = [ItemType.module(.playerEnters)]
        (level.modules?.array as? [Module])?.forEach { module in
            switch module {
            case let textModule as TextModule:
                modules.append(.module(.text(textModule)))
                
            default:
                break
            }
        }
        modules.append(.module(.addNewModule))
        snapshot.appendItems(modules, toSection: .modules)
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
                
            case .text(let textModule):
                let cell = self.collectionView.dequeueConfiguredReusableCell(using: textModuleCellRegistration, for: indexPath, item: itemIdentifier)
                cell.textModule = textModule
                cell.presentingViewController = self
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
            guard let level = (self.game.levels?.array as? [Level])?[self.selectedLevel] else {
                preconditionFailure("Atleast 1 level should exist")
            }
            
            let textModule = DataManager.shared.addTextModule(to: level)
            
            let newTextModuleType = ItemType.module(.text(textModule))
            
            var snapshot = self.collectionViewDataSource.snapshot()
            snapshot.insertItems([newTextModuleType], beforeItem: .module(.addNewModule))
            self.collectionViewDataSource.apply(snapshot)
            self.selectedModule = newTextModuleType
            self.showHideToolbar()
        }
    }
}

extension GameEditorViewController {
    private struct CreateNewGame: View {
        let createNewGameButtonTapped: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer()
                
                Text("No games")
                    .foregroundColor(Asset.Colors.Grayscale._10.swiftUIColor)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.bottom, 12)

                Text("Tap “+” to build your first game")
                    .foregroundColor(Asset.Colors.Grayscale._50.swiftUIColor)
                    .font(.system(size: 16))
                    .padding(.bottom, 39)
                
                Button(action: createNewGameButtonTapped) {
                    Text("Create Your First Game")
                        .foregroundColor(Asset.Colors.Grayscale._100.swiftUIColor)
                        .font(.system(size: 15, weight: .heavy))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 56)
                }
                .background(Image("level_selected").resizable())

                Spacer()
            }
        }
    }
    
    private struct Levels: View {
        @ObservedObject var game: Game
        @Binding var selectedLevel: Int
        @State private var levelSelected = 0
            
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(0 ..< (game.levels?.count ?? 0), id: \.self) { index in
                        Button {
                            selectLevel(index)
                        } label: {
                            Text("level \(index + 1)")
                                .font(.system(size: 11))
                                .foregroundColor(Asset.Colors.Grayscale._10.swiftUIColor)
                        }
                        .frame(width: 66)
                        .background(Image(levelSelected == index ? "level_selected" : "level_unselected"))
                    }
                    
                    ButtonWithRoundedCornerBackground(cornerRadius: 5, backgroundColor: Color(UIColor(hex: "#262522")!), borderColor: Color(UIColor(hex: "#262522")!), selectedStatebackgroundColor: .white, selectedStateBorderColor: .white, isSelected: .constant(false)) {
                        DataManager.shared.addLevel(to: game)
                        selectLevel((game.levels?.count ?? 0) - 1)
                    } content: {
                        Image("add_level")
                            .frame(width: 66)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        
        private func selectLevel(_ index: Int) {
            withAnimation(.linear(duration: 0.1)) {
                levelSelected = index
            }
            selectedLevel = index
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

extension GameEditorViewController: UICollectionViewDelegate {
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
        if self.itemIdentifier(from: indexPath) == self.selectedModule {
            self.selectedModule = nil
        } else {
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