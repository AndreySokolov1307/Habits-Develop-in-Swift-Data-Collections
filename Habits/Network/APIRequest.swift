//
//  APIRequest.swift
//  Habits
//
//  Created by Андрей Соколов on 07.11.2023.
//

import Foundation
import UIKit

protocol APIRequest {
    associatedtype Responce
    
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var postData: Data? { get }
}

extension APIRequest {
    var host: String { "localhost" }
    var port: Int { 8080 }
}

extension APIRequest {
    var queryItems: [URLQueryItem]? { nil }
    var postData: Data? { nil }
}

extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        }
        
        return request
    }
}

enum APIRequestError: Error {
    case itemsNotFound
    case requestFailed
}

extension APIRequest where Responce: Decodable {
    func send() async throws -> Responce {
        let (data, responce) = try await URLSession.shared.data(for: request)
        
        guard let urlResponce = responce as? HTTPURLResponse,
              urlResponce.statusCode == 200 else {
            throw APIRequestError.itemsNotFound
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Responce.self, from: data)
        
        return decoded
    }
}

enum ImageRequestError: Error {
    case imageDataMissing
    case couldNotInitializeFromData
}

extension APIRequest where Responce == UIImage {
    func send() async throws -> UIImage {
        let (data, responce) = try await URLSession.shared.data(for: request)
        
        guard let urlResponce = responce as? HTTPURLResponse,
              urlResponce.statusCode == 200 else {
            throw ImageRequestError.imageDataMissing
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageRequestError.couldNotInitializeFromData
        }
        
        return image
    }
}

extension APIRequest {
    func send() async throws -> Void {
        let (_, responce) = try await URLSession.shared.data(for: request)
        
        guard let httpResponce = responce as? HTTPURLResponse,
              httpResponce.statusCode == 200 else {
            throw APIRequestError.requestFailed
        }
    }
}
