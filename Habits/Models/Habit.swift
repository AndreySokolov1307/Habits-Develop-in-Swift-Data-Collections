//
//  Habit.swift
//  Habits
//
//  Created by Андрей Соколов on 07.11.2023.
//

import Foundation

struct Habit: Codable {
    let name: String
    let category: Category
    let info: String
}

extension Habit: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.name == rhs.name
    }
}

extension Habit: Comparable {
    static func < (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.name < rhs.name
    }
}
