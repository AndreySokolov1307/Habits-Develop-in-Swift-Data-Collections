//
//  HabitDetailViewController.swift
//  Habits
//
//  Created by Андрей Соколов on 06.11.2023.
//

import UIKit

class HabitDetailViewController: UIViewController {
    
    let habitDetailView = HabitDetailView()
    
    var habit: Habit!
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable {
            case leaders(count: Int)
            case remaining
        }
        
        enum Item: Hashable, Comparable {
            case single(_ stat: UserCount)
            case multiple(_ stats: UserCount)
            
            static func < (lhs: HabitDetailViewController.ViewModel.Item, rhs: HabitDetailViewController.ViewModel.Item) -> Bool {
                switch(lhs, rhs) {
                case (.single(let lCount), .single(let rCount)):
                    return lCount.count < rCount.count
                case (.multiple(let lCount), .multiple(let rCount)):
                    return lCount.count < rCount.count
                case (.single, .multiple):
                    return false
                case (.multiple, .single):
                    return true
                }
            }
        }
    }
    
    struct Model {
        var habitStatistic: HabitStatistics?
        var userCounts: [UserCount] {
            habitStatistic?.userCounts ?? []
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    var updateTimer: Timer?
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var habitStatisticsRequestTask: Task<Void, Never>? = nil
    deinit { habitStatisticsRequestTask?.cancel() }
    
    init?(habit: Habit) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = habitDetailView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                           repeats: true) { _ in
            self.update()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        habitDetailView.collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "UserCount")
        dataSource = createDataSource()
        habitDetailView.collectionView.dataSource = dataSource
        
        update()
    }
    
    private func setupUI() {
        habitDetailView.habitNameLabel.text = habit.name
        habitDetailView.categoryLabel.text = habit.category.name
        habitDetailView.infoLabel.text = habit.info
        let navBarAppereance = UINavigationBarAppearance()
        navBarAppereance.backgroundColor = .quaternarySystemFill
        navigationItem.scrollEdgeAppearance = navBarAppereance
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func update() {
        habitStatisticsRequestTask?.cancel()
        habitStatisticsRequestTask = Task {
            if let statistics = try? await HabitStatisticsRequest(habitNames: [habit.name]).send(),
               statistics.count > 0 {
                self.model.habitStatistic = statistics[0]
            } else {
                self.model.habitStatistic = nil
            }
        }
        self.updateCollectionView()
        habitStatisticsRequestTask = nil
    }
   
    private func updateCollectionView() {
        let items = (self.model.habitStatistic?.userCounts.map { ViewModel.Item.single($0) } ?? []).sorted(by: >)
        
        dataSource.applySnapshotUsing(sectionIDs: [.remaining], itemsBySection: [.remaining: items])
    }
    
    private func createDataSource() -> DataSourceType {
        return DataSourceType(collectionView: habitDetailView.collectionView) { (collectionView, indexPath, grouping) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCount", for: indexPath) as! UICollectionViewListCell
            
            var content = UIListContentConfiguration.subtitleCell()
            content.prefersSideBySideTextAndSecondaryText = true
            switch grouping {
            case .single(let userStat):
                content.text = userStat.user.name
                content.secondaryText = "\(userStat.count)"
                content.textProperties.font = .preferredFont(forTextStyle: .headline)
                content.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)
            default:
                break
            }
            cell.contentConfiguration = content
            
            return cell
        }
    }
    
}
