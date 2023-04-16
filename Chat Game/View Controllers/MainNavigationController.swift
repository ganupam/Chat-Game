//
//  MainNavigationController.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/10/23.
//

import UIKit

final class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.grayscale_80
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        let backIndicatorImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0))
        appearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorImage)
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.view.backgroundColor = UIColor(red: 0.089, green: 0.096, blue: 0.095, alpha: 1)
    }
}
