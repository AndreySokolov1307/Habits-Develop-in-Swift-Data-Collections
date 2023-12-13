//
//  UserStatistics.swift
//  Habits
//
//  Created by Андрей Соколов on 09.11.2023.
//

import Foundation

struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

extension UserStatistics: Codable {}
