//
//  Color.swift
//  Habits
//
//  Created by Андрей Соколов on 07.11.2023.
//

import Foundation
import UIKit


struct Color: Codable {
    let hue: Double
    let saturation: Double
    let brightness: Double
}

extension Color {
    enum CodingKeys: String, CodingKey {
        case hue = "h"
        case saturation = "s"
        case brightness = "b"
    }
}

extension Color {
    var uiColor: UIColor {
        return UIColor(hue: CGFloat(hue),
                       saturation: CGFloat(saturation),
                       brightness: CGFloat(brightness),
                       alpha: 1)
    }
}

extension Color: Hashable {}
