//
//  HabitStatistics.swift
//  Habits
//
//  Created by Андрей Соколов on 09.11.2023.
//

import Foundation

struct HabitStatistics {
    let habit: Habit
    let userCounts: [UserCount]
}
extension HabitStatistics: Codable {}

