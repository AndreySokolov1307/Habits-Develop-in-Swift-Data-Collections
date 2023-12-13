//
//  UserDetailView.swift
//  Habits
//
//  Created by Андрей Соколов on 09.11.2023.
//

import UIKit

class UserDetailView: UIView {

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
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let horizStackView : UIStackView = {
        let stackView = UIStackView()
         stackView.axis = .horizontal
         stackView.alignment = .center
         stackView.distribution = .fill
         stackView.spacing = 20
         return stackView
     }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = "User Name"
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "Bio"
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        horizStackView.addArrangedSubview(profileImageView)
        horizStackView.addArrangedSubview(userNameLabel)
        vertStackView.addArrangedSubview(bioLabel)
        addSubview(collectionView)
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            vertStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            vertStackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            vertStackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            profileImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: vertStackView.bottomAnchor, constant: 20)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                               heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 0,
                                                     trailing: 12)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 1)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader =
        NSCollectionLayoutBoundarySupplementaryItem(layoutSize:
                                                        headerSize,
                                                    elementKind: SectionHeader.kind.identifier,
                                                    alignment: .top)
        sectionHeader.pinToVisibleBounds = true

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20,
                                                        leading: 0,
                                                        bottom: 20,
                                                        trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
