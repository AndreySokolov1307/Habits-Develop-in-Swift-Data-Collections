//
//  ViewController.swift
//  Habits
//
//  Created by Андрей Соколов on 06.11.2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    let homeView = HomeView()
    
    typealias DataSourceType =
       UICollectionViewDiffableDataSource<ViewModel.Section,
       ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable {
            case leaderboard
            case followedUsers
        }
    
        enum Item: Hashable {
            case leaderboardHabit(name: String, leadingUserRanking:
               String?,
               secondaryUserRanking: String?)
            case followedUser(_ user: User, message: String)
    
            func hash(into hasher: inout Hasher) {
                switch self {
                case .leaderboardHabit(let name, _, _):
                    hasher.combine(name)
                case .followedUser(let User, _):
                    hasher.combine(User)
                }
            }
    
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.leaderboardHabit(let lName, _, _), .leaderboardHabit(let rName, _, _)):
                    return lName == rName
                case (.followedUser(let lUser, _), .followedUser(let rUser, _)):
                    return lUser == rUser
                default:
                    return false
                }
            }
        }
    }
    
    struct Model {
        var usersByID = [String: User]()
        var habitsByName = [String: Habit]()
        var habitStatistics = [HabitStatistics]()
        var userStatistics = [UserStatistics]()
    
        var currentUser: User {
            return Settings.shared.currentUser
        }
    
        var users: [User] {
            return Array(usersByID.values)
        }
    
        var habits: [Habit] {
            return Array(habitsByName.values)
        }
    
        var followedUsers: [User] {
            return Array(usersByID.filter {
                Settings.shared.followedUserIDs.contains($0.key)
            }.values)
        }
    
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
    
        var nonFavoriteHabits: [Habit] {
            return habits.filter { !favoriteHabits.contains($0) }
        }
    }
    
    var model = Model()
    var dataSource: DataSourceType!
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var userRequestTask: Task<Void, Never>? = nil
    var habitRequestTask: Task<Void, Never>? = nil
    var combinedStatisticsRequestTask: Task<Void, Never>? = nil
    deinit {
        userRequestTask?.cancel()
        habitRequestTask?.cancel()
        combinedStatisticsRequestTask?.cancel()
    }
    
    var updateTimer: Timer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        update()
    
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats:
           true) { _ in
            self.update()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        updateTimer?.invalidate()
        updateTimer = nil
    }
   
    override func loadView() {
        self.view = homeView
        homeView.collectionView.register(LeaderboardHabitCollectionViewCell.self,
                                         forCellWithReuseIdentifier: LeaderboardHabitCollectionViewCell.reuseIdentifier)
     
        homeView.collectionView.register(FollowedUserCollectionViewCell.self,
                                         forCellWithReuseIdentifier: FollowedUserCollectionViewCell.reuseIdentifier)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        userRequestTask = Task {
            if let users = try? await UserRequest().send() {
                self.model.usersByID = users
            }
            self.updateCollectionView()
        
            userRequestTask = nil
        }
        
        habitRequestTask = Task {
            if let habits = try? await HabitRequest().send() {
                self.model.habitsByName = habits
            }
            self.updateCollectionView()
        
            habitRequestTask = nil
        }
        
        dataSource = createDataSource()
        homeView.collectionView.dataSource = dataSource
        homeView.collectionView.setCollectionViewLayout(createLayout(), animated: false)
        
        for supplementaryView in SupplementaryView.allCases {
            supplementaryView.register(on: homeView.collectionView)
        }
    }
    
    
   private func update() {
        combinedStatisticsRequestTask?.cancel()
        combinedStatisticsRequestTask = Task {
            if let combinedStatistics = try? await
                CombinedStatisticsRequest().send() {
                self.model.userStatistics = combinedStatistics.userStatistics
                self.model.habitStatistics =
                combinedStatistics.habitStatistics
            } else {
                self.model.userStatistics = []
                self.model.habitStatistics = []
            }
            self.updateCollectionView()
            
            combinedStatisticsRequestTask = nil
        }
    }
    
    private func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        
        let leaderboardItems = model.habitStatistics.filter { statistic in
            return model.favoriteHabits.contains {
                $0.name == statistic.habit.name
            }
        }
            .sorted {
                $0.habit.name < $1.habit.name
            }
            .reduce(into: [ViewModel.Item]()) { partial, statistic in
                // Rank the user counts from highest to lowest
                let rankedUserCounts = statistic.userCounts.sorted { $0.count >
                   $1.count }
                // Find the index of the current user's count, keeping in mind that
                // it won't exist if the user hasn't logged that habit yet
                let myCountIndex = rankedUserCounts.firstIndex { $0.user.id ==
                   self.model.currentUser.id }
                
                func userRankingString(from userCount: UserCount) -> String {
                    var name = userCount.user.name
                    var ranking = ""
                
                    if userCount.user.id == self.model.currentUser.id {
                        name = "You"
                        ranking = " (\(ordinalString(from: myCountIndex!)))"
                    }
                
                    return "\(name) \(userCount.count)" + ranking
                }
                
                var leadingRanking: String?
                var secondaryRanking: String?

                // Examine the number of user counts for the statistic:
                switch rankedUserCounts.count {
                case 0:
                    // If 0, set the leader label to "Nobody Yet!" and leave the
                    //   secondary label `nil`
                    leadingRanking = "Nobody yet!"
                case 1:
                    // If 1, set the leader label to the only user and count
                    let onlyCount = rankedUserCounts.first!
                    leadingRanking = userRankingString(from: onlyCount)
                default:
                    // Otherwise, do the following:
                    // Set the leader label to the user count at index 0
                    leadingRanking = userRankingString(from: rankedUserCounts[0])
                
                    // Check whether the index of the current user's count exists and
                    //   is not 0
                    if let myCountIndex = myCountIndex, myCountIndex !=
                       rankedUserCounts.startIndex {
                        // If true, the user's count and ranking should be displayed
                        //   in the secondary label
                        secondaryRanking = userRankingString(from:
                           rankedUserCounts[myCountIndex])
                    } else {
                        // If false, the second-place user count should be displayed
                        secondaryRanking = userRankingString(from:
                           rankedUserCounts[1])
                    }
                }
                let leaderboardItem = ViewModel.Item.leaderboardHabit(name: statistic.habit.name, leadingUserRanking: leadingRanking, secondaryUserRanking: secondaryRanking)
                
                partial.append(leaderboardItem)
            }
        sectionIDs.append(.leaderboard)
        
        var itemsBySection = [ViewModel.Section.leaderboard: leaderboardItems]
        
        var followedUserItems = [ViewModel.Item]()
        
        func loggedHabitNames(for user: User) -> Set<String> {
            var names = [String]()
            
            if let stats = model.userStatistics.first(where: { $0.user == user }) {
                names = stats.habitCounts.map { $0.habit.name }
            }
            
            return Set(names)
        }
        
        // Get the current user's logged habits and extract the favorites
        let currentUserLoggedHabits = loggedHabitNames(for: model.currentUser)
        let favoriteLoggedHabits = Set(model.favoriteHabits.map { $0.name }).intersection(currentUserLoggedHabits)
        
        // Loop through all the followed users
        for followedUser in model.followedUsers.sorted(by:
           { $0.name < $1.name }) {
            let message: String
        
            let followedUserLoggedHabits = loggedHabitNames(for: followedUser)
            
            // If the users have a habit in common:
                let commonLoggedHabits =
                   followedUserLoggedHabits.intersection(currentUserLoggedHabits)
            
                if commonLoggedHabits.count > 0 {
                    // Pick the habit to focus on
                    let habitName: String
                    let commonFavoriteLoggedHabits = favoriteLoggedHabits.intersection(commonLoggedHabits)
                    
                    if commonFavoriteLoggedHabits.count > 0 {
                        habitName = commonFavoriteLoggedHabits.sorted().first!
                    } else {
                        habitName = commonLoggedHabits.sorted().first!
                    }
                    
                    
                    // Get the full statistics (all the user counts) for that habit
                    let habitStats = model.habitStatistics.first
                    { $0.habit.name == habitName }!
                    
                    // Get the ranking for each user
                    let rankedUserCounts = habitStats.userCounts.sorted
                    { $0.count > $1.count }
                    let currentUserRanking = rankedUserCounts.firstIndex
                    { $0.user == model.currentUser }!
                    let followedUserRanking = rankedUserCounts.firstIndex
                    { $0.user == followedUser }!
                    
                    // Construct the message depending on who's leading
                    if currentUserRanking < followedUserRanking {
                        message = "Currently #\(ordinalString(from: followedUserRanking)), behind you (#\(ordinalString(from: currentUserRanking))) in \(habitName).\nSend them a friendly reminder!"
                    } else if currentUserRanking > followedUserRanking {
                        message = "Currently #\(ordinalString(from: followedUserRanking)), ahead of you (#\(ordinalString(from: currentUserRanking))) in \(habitName).\nYou might catch up with a little extra effort!"
                    } else {
                        message = "You are tied at  \(ordinalString(from: followedUserRanking)) in \(habitName)! Now's your chance to pull ahead"
                    } 
                    // Otherwise, if the followed user has logged at least one habit:
                } else if followedUserLoggedHabits.count > 0 {
                    
                    // Get an arbitrary habit name
                    let habitName = followedUserLoggedHabits.sorted().first!
            
                    // Get the full statistics (all the user counts) for that habit
                    let habitStats = model.habitStatistics.first
                       { $0.habit.name == habitName }!
            
                    // Get the user's ranking for that habit
                    let rankedUserCounts = habitStats.userCounts.sorted
                       { $0.count > $1.count }
                    let followedUserRanking = rankedUserCounts.firstIndex
                       { $0.user == followedUser }!
            
                    // Construct the message
                    message = "Currently #\(ordinalString(from: followedUserRanking)), in \(habitName).\nMaybe you should give this habit a look "
                    
                    // Otherwise, this user hasn't done anything
                } else {
                    message = "This user doesn't seem to have done much yet. Check in to see if they need any help getting started."
                }

                followedUserItems.append(.followedUser(followedUser,
                   message: message))
        }
        
        sectionIDs.append(.followedUsers)
        itemsBySection[.followedUsers] = followedUserItems
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs,
                                      itemsBySection: itemsBySection)
    }
    static let formatter: NumberFormatter = {
        var f = NumberFormatter()
        f.numberStyle = .ordinal
        return f
    }()
    
    func ordinalString(from number: Int) -> String {
        return Self.formatter.string(from: NSNumber(integerLiteral:
           number + 1))!
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: homeView.collectionView) {
           (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .leaderboardHabit(let name, let leadingUserRanking,
               let secondaryUserRanking):
                let cell =
                   collectionView.dequeueReusableCell(withReuseIdentifier:
                                                        LeaderboardHabitCollectionViewCell.reuseIdentifier,
                                                      for: indexPath) as!
                   LeaderboardHabitCollectionViewCell
                cell.habitNameLabel.text = name
                cell.leaderLabel.text = leadingUserRanking
                cell.secondaryLabel.text = secondaryUserRanking
                cell.backgroundColor = Constants.favoriteHabitColor.withAlphaComponent(0.75)
                cell.layer.cornerRadius = 8
                cell.layer.shadowRadius = 3
                cell.layer.shadowColor = UIColor.systemGray3.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.layer.shadowOpacity = 1
                cell.layer.masksToBounds = false
                return cell
            case .followedUser(let user, let message):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                FollowedUserCollectionViewCell.reuseIdentifier,
                                                              for: indexPath) as!
                           FollowedUserCollectionViewCell
                cell.primaryTextLabel.text = user.name
                cell.secondaryTextLabel.text = message
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = {
            (collectionView, kind, indexPath) in guard let elementKind  = SupplementaryView(rawValue: kind) else {
                return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind.viewKind,
                                                                       withReuseIdentifier: elementKind.reuseIdentifier,
                                                                       for: indexPath)
            switch elementKind {
            case .leaderboardSectionHeader:
                let header = view as! NamedSectionHeaderView
                header.nameLabel.text = "Leaderboard"
                header.nameLabel.font = .preferredFont(forTextStyle: .largeTitle)
                header.alignLabelToTop()
                return header
            case .followedUserSectionHeader:
                let header = view as! NamedSectionHeaderView
                header.nameLabel.text = "Following"
                header.nameLabel.font = .preferredFont(forTextStyle: .title2)
                header.alignLabelToYCenter()
                return header
            default:
                return nil
            }
        }
        return dataSource
    }
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex,
           environment) -> NSCollectionLayoutSection? in
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .leaderboard:
                let leaderboardItemSize =
                   NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                   heightDimension: .fractionalHeight(0.3))
                let leaderboardItem = NSCollectionLayoutItem(layoutSize:
                   leaderboardItemSize)
    
                let verticalTrioSize = NSCollectionLayoutSize(widthDimension:
                   .fractionalWidth(0.75), heightDimension:
                   .fractionalWidth(0.75))
                let leaderboardVerticalTrio =
                   NSCollectionLayoutGroup.vertical(layoutSize:
                   verticalTrioSize, subitem: leaderboardItem, count: 3)
                leaderboardVerticalTrio.interItemSpacing = .fixed(10)
    
                let leaderboardSection = NSCollectionLayoutSection(group:
                   leaderboardVerticalTrio)
                leaderboardSection.interGroupSpacing = 20
    
                leaderboardSection.orthogonalScrollingBehavior =
                   .continuous
                leaderboardSection.contentInsets =
                   NSDirectionalEdgeInsets(top: 12, leading: 20,
                   bottom: 20, trailing: 20)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1) ,
                                                        heightDimension: .absolute(80))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                         elementKind: SupplementaryView.leaderboardSectionHeader.viewKind,
                                                                         alignment: .top)
                let background = NSCollectionLayoutDecorationItem.background(elementKind: SupplementaryView.leaderboardBackgroud.viewKind)
                
                leaderboardSection.boundarySupplementaryItems = [header]
                leaderboardSection.decorationItems = [background]
                leaderboardSection.supplementariesFollowContentInsets = false
    
                return leaderboardSection
            case .followedUsers:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(100))
                let followedUserItem = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension:.fractionalWidth(1),
                                                       heightDimension: .estimated(100))
                let followedUserGroup =
                NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitem: followedUserItem,
                                                   count: 1)
                
                let followedUserSection = NSCollectionLayoutSection(group: followedUserGroup)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1) ,
                                                        heightDimension: .absolute(60))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                         elementKind: SupplementaryView.followedUserSectionHeader.viewKind,
                                                                         alignment: .top)
                followedUserSection.boundarySupplementaryItems = [header]
                
                return followedUserSection
            }
        }
    
        return layout
    }
}

