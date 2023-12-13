//
//  FollowedUserCollectionViewCell.swift
//  Habits
//
//  Created by Андрей Соколов on 10.11.2023.
//

import Foundation
import UIKit

class FollowedUserCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "reuseIdentifierFollowed"
    
    let primaryTextLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.init(rawValue: 249.0), for: .vertical)
        return label
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(primaryTextLabel)
        addSubview(secondaryTextLabel)
        addSubview(separator)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            primaryTextLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            primaryTextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            primaryTextLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -8),
            
            secondaryTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            secondaryTextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            secondaryTextLabel.topAnchor.constraint(equalTo: primaryTextLabel.bottomAnchor, constant: 16),
            
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            separator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            separator.topAnchor.constraint(equalTo: secondaryTextLabel.bottomAnchor, constant: 8)
            
            
        
        ])
    }
}
