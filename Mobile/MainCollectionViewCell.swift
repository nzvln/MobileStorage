//
//  MainCollectionViewCell.swift
//  Mobile
//
//  Created by Nadia on 06.09.2022.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
        
    
        lazy var textLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.black
            label.font = .boldSystemFont(ofSize: 20)
            label.textAlignment = .center
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 15
            label.numberOfLines = 0
            
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.addSubview(textLabel)
            contentView.backgroundColor = UIColor.white
            layer.masksToBounds = true
            layer.cornerRadius = 16
            constraintsOfLabel()
        }
                
        func constraintsOfLabel() {
            NSLayoutConstraint.activate([
                textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
                textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
                textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
            ])
        }
        
        func setup(with text: String) {
            textLabel.text = text
        }
        override func prepareForReuse() {
            super.prepareForReuse()
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }


