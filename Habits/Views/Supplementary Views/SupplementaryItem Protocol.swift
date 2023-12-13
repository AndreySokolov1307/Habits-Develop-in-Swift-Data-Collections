//
//  SupplementaryItem Protocol.swift
//  Habits
//
//  Created by Андрей Соколов on 11.11.2023.
//

import Foundation
import UIKit

enum SupplementaryItemtype {
    case collectionSupplementaryView
    case layoutDecorationView
}

protocol SupplementaryItem {
    associatedtype ViewClass: UICollectionReusableView
    
    var itemType: SupplementaryItemtype { get }
    
    var reuseIdentifier: String { get }
    var viewKind: String { get }
    var viewClass: ViewClass.Type { get }
}

extension SupplementaryItem {
    func register(on collectionView: UICollectionView) {
        switch self.itemType {
        case .collectionSupplementaryView:
            collectionView.register(viewClass.self,
                                    forSupplementaryViewOfKind: viewKind,
                                    withReuseIdentifier: reuseIdentifier)
        case .layoutDecorationView:
            collectionView.collectionViewLayout.register(viewClass.self,
                                                         forDecorationViewOfKind: viewKind)
        
        }
    }
}
