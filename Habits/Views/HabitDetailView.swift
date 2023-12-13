//
//  HabitDetailView.swift
//  Habits
//
//  Created by Андрей Соколов on 09.11.2023.
//

import UIKit

class HabitDetailView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let vertStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let horizStackView : UIStackView = {
        let stackView = UIStackView()
         stackView.axis = .horizontal
         stackView.alignment = .firstBaseline
         stackView.distribution = .equalSpacing
         stackView.spacing = 12
         return stackView
     }()
    
    let habitNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = "Habit name"
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "Categorry"
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Info"
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(vertStackView)
        vertStackView.addArrangedSubview(horizStackView)
        horizStackView.addArrangedSubview(habitNameLabel)
        horizStackView.addArrangedSubview(categoryLabel)
        vertStackView.addArrangedSubview(infoLabel)
        addSubview(collectionView)
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            vertStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            vertStackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            vertStackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            collectionView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: vertStackView.bottomAnchor, constant: 20)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 0,
                                                     trailing: 12)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20,
                                                        leading: 0,
                                                        bottom: 20,
                                                        trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }

}
