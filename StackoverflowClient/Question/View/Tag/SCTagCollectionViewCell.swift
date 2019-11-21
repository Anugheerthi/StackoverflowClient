//
//  SCTagCollectionViewCell.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

class SCTagCollectionViewCell: UICollectionViewCell {
    
    private enum Constants {
        static let borderWidth: CGFloat = 0.5
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func config(_ tag: String) {
        titleLabel.text = tag
        titleLabel.text = tag
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
}
