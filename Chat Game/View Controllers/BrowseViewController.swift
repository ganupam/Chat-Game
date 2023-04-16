//
//  BrowseViewController.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/15/23.
//

import Foundation
import UIKit

final class BrowseViewController: BaseViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(named: "cards"), selectedImage: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Browse"
    }
}
