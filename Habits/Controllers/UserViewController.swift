//
//  PeopleViewController.swift
//  Habits
//
//  Created by Андрей Соколов on 06.11.2023.
//

import UIKit

class UserViewController: UIViewController {

    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        typealias Section = Int
        
        struct Item: Hashable {
            let user: User
            let isFollowed: Bool
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(user)
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                return lhs.user == rhs.user
            }
        }
    }
    
    struct Model {
        var usersById = [String : User]()
        var followedUsers: [User] {
            return Array(usersById.filter {
                Settings.shared.followedUserIDs.contains($0.key)
            }.values)
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    var userRequestTask: Task<Void, Never>? = nil
    deinit { userRequestTask?.cancel() }
    
    var userView = UserView()
    
    override func loadView() {
        self.view = userView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        userView.collectionView.register(UICollectionViewListCell.self,
                                           forCellWithReuseIdentifier: "User")
        
        userView.collectionView.delegate = self
        
        dataSource = createDataSource()
        userView.collectionView.dataSource = dataSource
        
        update()
    }
  
    private func update() {
        userRequestTask?.cancel()
        userRequestTask = Task {
            if let users = try? await UserRequest().send() {
                self.model.usersById = users
            } else {
                self.model.usersById = [:]
            }
            self.updateCollectionView()
            
            userRequestTask = nil
        }
    }

    private func updateCollectionView() {
        let users = model.usersById.values.sorted().reduce(into: [ViewModel.Item]()) { partial, user in
            partial.append(ViewModel.Item(user: user, isFollowed: model.followedUsers.contains(user)))
        }
        let itemBySection = [0 : users]
        
        dataSource.applySnapshotUsing(sectionIDs: [0],
                                      itemsBySection: itemBySection)
    }
    
    private func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: userView.collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "User", for: indexPath) as! UICollectionViewListCell
            var content = cell.defaultContentConfiguration()
            
            content.text = item.user.name
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11,
                                                                       leading: 8,
                                                                       bottom: 11,
                                                                       trailing: 8)
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            
            var backgroundConfigiration = UIBackgroundConfiguration.clear()
            backgroundConfigiration.backgroundColor = item.user.color?.uiColor ?? UIColor.systemGray4
            cell.backgroundConfiguration = backgroundConfigiration
            
            
            return cell
        }
        return dataSource
    }
}


//MARK: - UICollectionViewDelegate

extension UserViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil,
                                                previewProvider: nil) { (elements) -> UIMenu? in
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            let favoriteToggle = UIAction(title: item.isFollowed ? "Unfollow" : "Follow") {
                action in
                Settings.shared.toggleFollowed(user: item.user)
                self.updateCollectionView()
            }
             return UIMenu(title: "",
                           image: nil,
                           identifier: nil,
                           options: [],
                           children: [favoriteToggle])
        }
        return config
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        self.navigationController?.pushViewController(UserDetailViewController(user: item.user)!, animated: true)
    }
}
