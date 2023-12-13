//
//  LoggedHabit.swift
//  Habits
//
//  Created by Андрей Соколов on 10.11.2023.
//

import Foundation

struct LoggedHabit {
    let userID: String
    let habitName: String
    let timestamp: Date
}

extension LoggedHabit: Codable {}
