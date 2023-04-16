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
        appearance.backgroundColor = .header_background

        let itemAppearance = UITabBarItemAppearance(style: .stacked)
        itemAppearance.normal.iconColor = .grayscale_20
        itemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.grayscale_20]
        itemAppearance.selected.iconColor = .primary
        itemAppearance.selected.titleTextAttributes = [.foregroundColor : UIColor.primary]
        appearance.stackedLayoutAppearance = itemAppearance
        self.tabBar.standardAppearance = appearance
        //self.tabBar.scrollEdgeAppearance = appearance
        
        let createTab = MainNavigationController(rootViewController: GameCreatorViewController())
        self.viewControllers = [FavoritesViewController(), BrowseViewController(), createTab, SpendViewController(), AccountViewController()]
        self.selectedIndex = 2
    }
}
