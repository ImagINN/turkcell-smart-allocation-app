//
//  EndpointURLHandler.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import Foundation

public enum EndpointURLHandler {
    
    // MARK: - Base URLs
    
    static let requestsBaseUrl = URL(string: "http://localhost:3001/api")
    
    // MARK: - Endpoints
    
    case requests
    case requestDetail(id: String)
    case userRequests(userId: String)
    
    // MARK: - URL Builder
    
    var url: URL {
        switch self {
        case .requests:
            guard let baseUrl = Self.requestsBaseUrl else {
                fatalError("Invalid requests base URL")
            }
            return baseUrl.appendingPathComponent("requests")
            
        case let .requestDetail(id):
            guard let baseUrl = Self.requestsBaseUrl else {
                fatalError("Invalid requests base URL")
            }
            return baseUrl
                .appendingPathComponent("requests")
                .appendingPathComponent(id)
            
        case let .userRequests(userId):
            guard let baseUrl = Self.requestsBaseUrl else {
                fatalError("Invalid requests base URL")
            }
            var components = URLComponents(
                url: baseUrl.appendingPathComponent("requests"),
                resolvingAgainstBaseURL: false
            )
            components?.queryItems = [
                URLQueryItem(name: "userId", value: userId)
            ]
            return components?.url ?? baseUrl.appendingPathComponent("requests")
        }
    }
}
