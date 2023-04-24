//
//  LevelSettingCollectionViewCell.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/16/23.
//

import UIKit

final class LevelSettingCollectionViewCell: UICollectionViewCell {
    var buttonTapped: (() -> Void)!
    
    var title: String = "" {
        didSet {
            var attributedTitle = AttributedString(self.title)
            attributedTitle.font = .systemFont(ofSize: 12)
            self.button.configuration?.attributedTitle = attributedTitle
        }
    }
    
    var image: UIImage? {
        didSet {
            self.button.configuration?.image = self.image
        }
    }
    
    private lazy var button = {
        let button = UIButton(type: .custom, primaryAction: UIAction { [weak self] _ in
            self?.buttonTapped()
        })
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.imagePadding = 5
        config.baseForegroundColor = Asset.Colors.Grayscale._10.color
        button.tintColor = Asset.Colors.Grayscale._80.color
        button.configuration = config
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.button.frame = self.contentView.bounds
        self.backgroundView = UIView()
        self.contentView.addSubview(self.button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
