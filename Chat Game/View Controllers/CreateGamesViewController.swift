//
//  CreateGamesViewController.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 5/4/23.
//

import UIKit
import SwiftUI

final class CreateGamesViewController: BaseViewController {
    private var notificationToken: NotificationToken?
    
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
        
        let rootView = RootView() { [weak self] in
            self?.askForNewGameTitle()
        } gameSelected: {
            self.navigationController?.pushViewController(GameEditorViewController(game: $0), animated: true)
        }
            .environment(\.managedObjectContext, DataManager.shared.viewContext)
        
        let vc = UIHostingController(rootView: rootView)
        self.view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.backgroundColor = .clear
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[createNewGameView]|", metrics: nil, views: ["createNewGameView" : vc.view!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[createNewGameView]|", metrics: nil, views: ["createNewGameView" : vc.view!]))
        
        let button = UIButton(type: .custom, primaryAction: UIAction(image: UIImage(systemName: "plus"), handler: { [weak self] _ in
            self?.askForNewGameTitle()
        }))
        button.layer.backgroundColor = UIColor(hex: "#262522")?.cgColor
        button.layer.cornerRadius = 5
        button.bounds.size =  CGSize(width: 66, height: 34)
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func askForNewGameTitle() {
        let alert = UIAlertController(title: "Game title", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let confirmAction = UIAlertAction(title: "Create", style: .default) { [weak alert, weak self] _ in
            let title = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
            self?.createNewGameAndPushVC(title: title)
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
    
    private func createNewGameAndPushVC(title: String) {
        let game = DataManager.shared.createNewGame(title)
        
        self.navigationController?.pushViewController(GameEditorViewController(game: game), animated: true)
    }
}

extension CreateGamesViewController {
    private struct RootView: View {
        let createNewGameButtonTapped: () -> Void
        let gameSelected: (Game) -> Void
        
        @FetchRequest(entity: Game.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Game.creationDate, ascending: false)])
        private var games: FetchedResults<Game>
        
        var body: some View {
            if games.isEmpty {
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
            } else {
                GamesList(gameSelected: gameSelected)
            }
        }
    }
}

private struct GamesList: View {
    @FetchRequest(entity: Game.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Game.creationDate, ascending: false)])
    private var games: FetchedResults<Game>
    
    let gameSelected: (Game) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(games) { game in
                    ButtonWithRoundedCornerBackground(cornerRadius: 5, backgroundColor: Asset.Colors.Grayscale._80.swiftUIColor, selectedStatebackgroundColor: .clear, isSelected: .constant(false)) {
                        gameSelected(game)
                    } content: {
                        HStack {
                            Text(game.title ?? "")
                                .foregroundColor(Asset.Colors.Grayscale._10.swiftUIColor)
                                .font(.system(size: 13))
                                .padding(.vertical, 10)
                                .padding(.leading, 10)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
    }
}
