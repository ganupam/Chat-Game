//
//  MainTabBarViewController.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/15/23.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Asset.Colors.Utility.headerBackground.color

        let itemAppearance = UITabBarItemAppearance(style: .stacked)
        itemAppearance.normal.iconColor = Asset.Colors.Grayscale._20.color
        itemAppearance.normal.titleTextAttributes = [.foregroundColor : Asset.Colors.Grayscale._20.color]
        itemAppearance.selected.iconColor = Asset.Colors.primary.color
        itemAppearance.selected.titleTextAttributes = [.foregroundColor : Asset.Colors.primary.color]
        appearance.stackedLayoutAppearance = itemAppearance
        self.tabBar.standardAppearance = appearance
        
        let createTab = MainNavigationController(rootViewController: CreateGamesViewController())
        self.viewControllers = [FavoritesViewController(), BrowseViewController(), createTab, SpendViewController(), AccountViewController()]
        self.selectedIndex = 2
    }
}
