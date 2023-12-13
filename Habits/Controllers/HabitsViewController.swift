//
//  HabitsViewController.swift
//  Habits
//
//  Created by Андрей Соколов on 06.11.2023.
//

import UIKit

class HabitsViewController: UIViewController {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var habitsRequestTask: Task<Void, Never>? = nil
    
    //MARK: - Deinit
    deinit {
        habitsRequestTask?.cancel()
    }
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case favorites
            case category(_ category: Category)
            
            static func < (lhs: HabitsViewController.ViewModel.Section, rhs: HabitsViewController.ViewModel.Section) -> Bool {
                switch (lhs, rhs) {
                case (.category(let l), .category(let r)):
                    return l.name < r.name
                case (.favorites, _):
                    return true
                case (_, .favorites):
                    return false
                }
            }
            
            var sectionColor: UIColor {
                switch self {
                case .favorites:
                    return Constants.favoriteHabitColor
                case .category(let category):
                    return category.color.uiColor
                }
            }
        }
        
        typealias Item = Habit
    }
    
    struct Model {
        var habitsByName = [String : Habit]()
        var favoriteHabits: [Habit] {
           return Settings.shared.favoriteHabits
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    var habitsView = HabitsView()
    
    
    override func loadView() {
        self .view = habitsView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        habitsView.collectionView.register(UICollectionViewListCell.self,
                                           forCellWithReuseIdentifier: "Habit")
        habitsView.collectionView.register(NamedSectionHeaderView.self,
                                           forSupplementaryViewOfKind: SectionHeader.kind.identifier,
                                           withReuseIdentifier: SectionHeader.reuse.identifier)
        habitsView.collectionView.delegate = self
        dataSource = createDataSource()
        habitsView.collectionView.dataSource = dataSource
    }
    
    private func update() {
        habitsRequestTask?.cancel()
        habitsRequestTask = Task {
            if let habits = try? await HabitRequest().send() {
                self.model.habitsByName = habits
            } else {
                self.model.habitsByName = [:]
            }
            self.updateCollectionView()
            
            habitsRequestTask = nil
        }
    }
    
    private func updateCollectionView() {
        var itemBySection = model.habitsByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habit in
            let item = habit
            
            let section: ViewModel.Section
            if model.favoriteHabits.contains(habit) {
                section = .favorites
            } else {
                section = .category(habit.category)
            }
            
            partial[section, default: []].append(item)
        }
        itemBySection = itemBySection.mapValues { $0.sorted() }
        
        let sectionIDs = itemBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs,
                                      itemsBySection: itemBySection)
    }
    
    func configureCell(_ cell: UICollectionViewListCell, withItem item: ViewModel.Item ) {
        
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        cell.contentConfiguration = content
    }
    
    private func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: habitsView.collectionView) { (collectionView,indexPath,item) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Habit", for: indexPath) as! UICollectionViewListCell
            
            self.configureCell(cell, withItem: item)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            
            let header  = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier, for: indexPath) as! NamedSectionHeaderView
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .favorites:
                header.nameLabel.text = "Favorites"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            
            header.backgroundColor = section.sectionColor
            return header
        }
        
        return dataSource
    }
}

//MARK: - UICollectionViewDelegate

extension HabitsViewController: UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
         let config = UIContextMenuConfiguration(identifier: nil,
                                                 previewProvider: nil) { _ in
             let item = self.dataSource.itemIdentifier(for: indexPath)!
             
             let favoriteToggle = UIAction(title: self.model.favoriteHabits.contains(item) ? "Unfavorite" : "Favorite") { (action) in
                 Settings.shared.toggleFavorite(item)
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
        
        self.navigationController?.pushViewController(HabitDetailViewController(habit: item)!, animated: true)
    }
}
