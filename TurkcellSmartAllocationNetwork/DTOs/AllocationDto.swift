//
//  AllocationDto.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Allocation Status

enum AllocationStatus: String, Decodable, Sendable {
    case assigned = "ASSIGNED"
    case completed = "COMPLETED"
    
    var displayName: String {
        switch self {
        case .assigned: return "Atandı"
        case .completed: return "Tamamlandı"
        }
    }
}

// MARK: - Allocation Full DTO

struct AllocationFullDto: Decodable, Sendable {
    let id: String
    let requestId: String
    let resourceId: String
    let priorityScore: Int
    let status: AllocationStatus
    let timestamp: Date
    let expectedCompletionAt: Date?
    let completedAt: Date?
    let request: AllocationRequestDto
    let resource: AllocationResourceDto
}

// MARK: - Allocation Request DTO

struct AllocationRequestDto: Decodable, Sendable {
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

// MARK: - Allocation Resource DTO

struct AllocationResourceDto: Decodable, Sendable {
    let id: String
    let resourceType: String
    let capacity: Int
    let city: String
    let status: String
}

// MARK: - Allocation Filter Parameters

struct AllocationFilterParams {
    var status: AllocationStatus?
    
    init(status: AllocationStatus? = nil) {
        self.status = status
    }
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let status = status {
            items.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        
        return items
    }
}
