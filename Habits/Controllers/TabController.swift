//
//  TabController.swift
//  Habits
//
//  Created by Андрей Соколов on 06.11.2023.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .quaternarySystemFill
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTabs() {
        
        let home = self.createNavigationController(with: "Home", image: UIImage(systemName: "house.fill")!, vc: HomeViewController())
        let habits = self.createNavigationController(with: "Habits", image: UIImage(systemName: "star.fill")!, vc: HabitsViewController())
        let people = self.createNavigationController(with: "People", image: UIImage(systemName: "person.2.fill")!, vc: UserViewController())
        let logHabit = self.createNavigationController(with: "Log Habit", image: UIImage(systemName: "checkmark.square.fill")!, vc: LogHabitViewController())
        
        self.setViewControllers([home,habits,people,logHabit], animated: true)
    }
    
    private func createNavigationController(with title: String, image: UIImage, vc: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: vc)
        
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        navController.viewControllers.first?.navigationItem.title = title
        
        return navController
    }
}
