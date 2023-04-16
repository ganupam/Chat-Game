//
//  BaseViewController.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/13/23.
//

import UIKit

class BaseViewController: UIViewController {
    private let patternImageView = {
        let patternImageView = UIImageView(image: UIImage(named: "tile")?.resizableImage(withCapInsets: .zero, resizingMode: .tile))
        patternImageView.translatesAutoresizingMaskIntoConstraints = false
        return patternImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backButtonTitle = ""
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor(red: 0.089, green: 0.096, blue: 0.095, alpha: 1)

        self.view.addSubview(self.patternImageView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[patternImageView]|", metrics: nil, views: ["patternImageView" : self.patternImageView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[patternImageView]|", metrics: nil, views: ["patternImageView" : self.patternImageView]))
    }
}
