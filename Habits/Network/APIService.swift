//
//  APIService.swift
//  Habits
//
//  Created by Андрей Соколов on 07.11.2023.
//

import Foundation
import UIKit

struct HabitRequest: APIRequest {
    typealias Responce = [String : Habit]
    
    var habitName: String?
    
    var path: String { "/habits" }
}


struct UserRequest: APIRequest {
    typealias Responce = [String : User]
    
    var path: String { "/users" }
}

struct HabitStatisticsRequest: APIRequest {
    typealias Responce = [HabitStatistics]
    
    var path: String {"/habitStats"}
    
    var habitNames: [String]?
    
    var queryItems: [URLQueryItem]? {
        if let habitNames = habitNames {
            return [URLQueryItem(name: "names", value: habitNames.joined(separator: ","))]
        } else {
            return nil
        }
    }
}

struct UserStatisticsRequest: APIRequest {
    
    typealias Responce = [UserStatistics]
    
    var userIDs: [String]?

    var path: String { "/userStats" }

    var queryItems: [URLQueryItem]? {
        if let userIDs = userIDs {
            return [URLQueryItem(name: "ids", value: userIDs.joined(separator: ","))]
        } else {
            return nil
        }
    }
}

struct HabitLeadStatisticsRequest: APIRequest {
    
    typealias Responce =  UserStatistics

    var userID: String

    var path: String { "/userLeadingStats/\(userID)" }
}

struct ImageRequest: APIRequest {
    
    typealias Responce = UIImage
    
    var imageID: String
    
    var path: String {"/images/" + imageID }
}

struct LogHabitRequest: APIRequest {
    typealias Responce = Void
    
    var loggedHabit: LoggedHabit
    
    var path: String { "/loggedHabit"}
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return try! encoder.encode(loggedHabit)
    }
}

struct CombinedStatisticsRequest: APIRequest {
    typealias Responce = CombinedStatistics
    
    var path: String {"/combinedStats"}
}
