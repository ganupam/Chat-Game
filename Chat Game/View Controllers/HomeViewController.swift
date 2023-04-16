//
//  HomeViewController.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/10/23.
//

import UIKit

final class HomeViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Browse Games"
        
        let button = UIButton(primaryAction: UIAction(title: "Test", handler: { [weak self] _ in
            guard let self else { return }
            
            self.navigationController?.pushViewController(GameCreatorViewController(), animated: true)
        }))
        button.frame = CGRect(x: 200, y: 200, width: 200, height: 44)
        self.view.addSubview(button)
    }
}

