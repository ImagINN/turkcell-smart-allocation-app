//
//  ResourceDto.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Resource Status

enum ResourceStatus: String, Decodable, Sendable {
    case available = "AVAILABLE"
    case busy = "BUSY"
    
    var displayName: String {
        switch self {
        case .available: return "Müsait"
        case .busy: return "Meşgul"
        }
    }
}

// MARK: - Resource DTO (Full)

struct ResourceFullDto: Decodable, Sendable {
    let id: String
    let resourceType: String
    let capacity: Int
    let city: String
    let status: ResourceStatus
    let allocations: [ResourceAllocationDto]
    let activeAllocations: Int
    let utilization: Int
}

// MARK: - Resource Allocation DTO

struct ResourceAllocationDto: Decodable, Sendable {
    let id: String
    let requestId: String
    let resourceId: String
    let priorityScore: Int
    let status: String
    let timestamp: Date
    let expectedCompletionAt: Date?
    let completedAt: Date?
    let request: ResourceRequestDto
}

// MARK: - Resource Request DTO (Nested in Allocation)

struct ResourceRequestDto: Decodable, Sendable {
    let id: String
    let userId: String
    let service: String
    let requestType: String
    let urgency: String
    let status: String
    let createdAt: Date
    let queuedAt: Date?
    let processedAt: Date?
    let user: UserDto
}

// MARK: - Resource Filter Parameters

struct ResourceFilterParams {
    var city: String?
    var status: ResourceStatus?
    
    init(city: String? = nil, status: ResourceStatus? = nil) {
        self.city = city
        self.status = status
    }
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let city = city, !city.isEmpty {
            items.append(URLQueryItem(name: "city", value: city))
        }
        
        if let status = status {
            items.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        
        return items
    }
}
