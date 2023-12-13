//
//  SupplementaryVIew.swift
//  Habits
//
//  Created by Андрей Соколов on 11.11.2023.
//

import Foundation
import UIKit

enum SupplementaryView: String, CaseIterable, SupplementaryItem {
    case leaderboardSectionHeader
    case leaderboardBackgroud
    case followedUserSectionHeader
    
    var reuseIdentifier: String {
        return rawValue
    }
    
    var viewKind: String {
        return rawValue
    }
    
    var viewClass: UICollectionReusableView.Type {
        switch self {
        case .leaderboardBackgroud:
            return SectionBackgroundView.self
        default :
            return NamedSectionHeaderView.self
        }
    }
    
    var itemType: SupplementaryItemtype {
        switch self {
        case .leaderboardBackgroud:
            return .layoutDecorationView
        default:
            return .collectionSupplementaryView
        }
    }
}
