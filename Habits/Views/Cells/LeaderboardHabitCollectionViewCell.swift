//
//  LeaderboardHabitCollectionViewCell.swift
//  Habits
//
//  Created by Андрей Соколов on 10.11.2023.
//

import UIKit

class LeaderboardHabitCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "reuseIdentifier"
    
    let habitNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let leaderLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubview(habitNameLabel)
        addSubview(leaderLabel)
        addSubview(secondaryLabel)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            habitNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            habitNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            habitNameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -8),
            
            leaderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            leaderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 8),
            leaderLabel.bottomAnchor.constraint(equalTo: secondaryLabel.topAnchor, constant: -8),
            
            secondaryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            secondaryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 8),
            secondaryLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ])
    }
    
}
