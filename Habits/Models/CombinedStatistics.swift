//
//  CombinedStatistics.swift
//  Habits
//
//  Created by Андрей Соколов on 10.11.2023.
//

import Foundation

struct CombinedStatistics {
    let userStatistics: [UserStatistics]
    let habitStatistics: [HabitStatistics]
}

extension CombinedStatistics: Codable {}
