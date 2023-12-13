//
//  Category.swift
//  Habits
//
//  Created by Андрей Соколов on 07.11.2023.
//

import Foundation
import UIKit

struct Category: Codable {
    let name: String
    let color: Color
}

extension Category: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.name == rhs.name
    }
}
