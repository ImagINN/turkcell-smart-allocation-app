//
//  RequestDto.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import Foundation

// MARK: - Request DTO

struct RequestDto: Decodable, Sendable {
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
    let allocation: AllocationDto?
    let priorityScore: Int
}

// MARK: - User DTO

struct UserDto: Decodable, Sendable {
    let id: String
    let name: String
    let email: String
    let password: String?
    let city: String
    let role: String
}

// MARK: - Allocation DTO

struct AllocationDto: Decodable, Sendable {
    let id: String
    let requestId: String
    let resourceId: String
    let priorityScore: Int
    let status: String
    let timestamp: Date
    let expectedCompletionAt: Date?
    let completedAt: Date?
    let resource: ResourceDto
}

// MARK: - Resource DTO

struct ResourceDto: Decodable, Sendable {
    let id: String
    let resourceType: String
    let capacity: Int
    let city: String
    let status: String
}
