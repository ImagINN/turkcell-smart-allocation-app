//
//  EndpointURLHandler.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import Foundation

public enum EndpointURLHandler {
    
    // MARK: - Base URLs
    
    static let baseUrl = URL(string: "http://localhost:3001/api")
    
    // MARK: - Request Endpoints
    
    case requests
    case requestDetail(id: String)
    case userRequests(userId: String)
    
    // MARK: - Resource Endpoints
    
    case resources
    case resourcesFiltered(city: String?, status: String?)
    case resourceDetail(id: String)
    
    // MARK: - Allocation Endpoints
    
    case allocations
    case allocationsFiltered(status: String?)
    case allocationDetail(id: String)
    
    // MARK: - Dashboard Endpoints
    
    case dashboardSummary
    
    // MARK: - URL Builder
    
    var url: URL {
        guard let baseUrl = Self.baseUrl else {
            fatalError("Invalid base URL")
        }
        
        switch self {
            
        // MARK: Request URLs
            
        case .requests:
            return baseUrl.appendingPathComponent("requests")
            
        case let .requestDetail(id):
            return baseUrl
                .appendingPathComponent("requests")
                .appendingPathComponent(id)
            
        case let .userRequests(userId):
            var components = URLComponents(
                url: baseUrl.appendingPathComponent("requests"),
                resolvingAgainstBaseURL: false
            )
            components?.queryItems = [
                URLQueryItem(name: "userId", value: userId)
            ]
            return components?.url ?? baseUrl.appendingPathComponent("requests")
            
        // MARK: Resource URLs
            
        case .resources:
            return baseUrl.appendingPathComponent("resources")
            
        case let .resourcesFiltered(city, status):
            var components = URLComponents(
                url: baseUrl.appendingPathComponent("resources"),
                resolvingAgainstBaseURL: false
            )
            
            var queryItems: [URLQueryItem] = []
            
            if let city = city, !city.isEmpty {
                queryItems.append(URLQueryItem(name: "city", value: city))
            }
            
            if let status = status, !status.isEmpty {
                queryItems.append(URLQueryItem(name: "status", value: status))
            }
            
            if !queryItems.isEmpty {
                components?.queryItems = queryItems
            }
            
            return components?.url ?? baseUrl.appendingPathComponent("resources")
            
        case let .resourceDetail(id):
            return baseUrl
                .appendingPathComponent("resources")
                .appendingPathComponent(id)
            
        // MARK: Allocation URLs
            
        case .allocations:
            return baseUrl.appendingPathComponent("allocations")
            
        case let .allocationsFiltered(status):
            var components = URLComponents(
                url: baseUrl.appendingPathComponent("allocations"),
                resolvingAgainstBaseURL: false
            )
            
            if let status = status, !status.isEmpty {
                components?.queryItems = [
                    URLQueryItem(name: "status", value: status)
                ]
            }
            
            return components?.url ?? baseUrl.appendingPathComponent("allocations")
            
        case let .allocationDetail(id):
            return baseUrl
                .appendingPathComponent("allocations")
                .appendingPathComponent(id)
            
        // MARK: Dashboard URLs
            
        case .dashboardSummary:
            return baseUrl
                .appendingPathComponent("dashboard")
                .appendingPathComponent("summary")
        }
    }
}

// MARK: - Convenience Methods

extension EndpointURLHandler {
    
    // MARK: Resource Convenience
    
    /// Tüm kaynakları getirmek için URL
    static var allResources: URL {
        EndpointURLHandler.resources.url
    }
    
    /// Şehre göre filtrelenmiş kaynaklar için URL
    static func resourcesByCity(_ city: String) -> URL {
        EndpointURLHandler.resourcesFiltered(city: city, status: nil).url
    }
    
    /// Duruma göre filtrelenmiş kaynaklar için URL
    static func resourcesByStatus(_ status: ResourceStatus) -> URL {
        EndpointURLHandler.resourcesFiltered(city: nil, status: status.rawValue).url
    }
    
    // MARK: Request Convenience
    
    /// Tüm talepleri getirmek için URL
    static var allRequests: URL {
        EndpointURLHandler.requests.url
    }
    
    // MARK: Allocation Convenience
    
    /// Tüm atamaları getirmek için URL
    static var allAllocations: URL {
        EndpointURLHandler.allocations.url
    }
    
    /// Atanmış (ASSIGNED) atamaları getirmek için URL
    static var assignedAllocations: URL {
        EndpointURLHandler.allocationsFiltered(status: AllocationStatus.assigned.rawValue).url
    }
    
    /// Tamamlanmış (COMPLETED) atamaları getirmek için URL
    static var completedAllocations: URL {
        EndpointURLHandler.allocationsFiltered(status: AllocationStatus.completed.rawValue).url
    }
    
    /// Duruma göre filtrelenmiş atamalar için URL
    static func allocationsByStatus(_ status: AllocationStatus) -> URL {
        EndpointURLHandler.allocationsFiltered(status: status.rawValue).url
    }
}
