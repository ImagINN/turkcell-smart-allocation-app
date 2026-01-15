//
//  DashboardSummaryDto.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Dashboard Summary Response

struct DashboardSummaryDto: Decodable, @unchecked Sendable {
    let stats: DashboardStatsDto
    let automationStatus: AutomationStatusDto
    let resourceUtilization: [ResourceUtilizationDto]
    let resourcesByCity: [String: CityResourceDto]
    let recentAllocations: [RecentAllocationDto]
    let recentLogs: [RecentLogDto]
    let priorityQueue: [PriorityQueueItemDto]
    let breakdown: BreakdownDto
}

// MARK: - Stats

struct DashboardStatsDto: Decodable {
    let pendingRequests: Int
    let activeAllocations: Int
    let completedAllocations: Int
    let totalResources: Int
    let todayCompleted: Int
    let queuedRequests: Int
}

// MARK: - Automation Status

struct AutomationStatusDto: Decodable {
    let isRunning: Bool
    let config: AutomationConfigDto
}

struct AutomationConfigDto: Decodable {
    let REQUEST_INTERVAL: Int
    let ALLOCATION_INTERVAL: Int
    let COMPLETION_INTERVAL: Int
    let MIN_COMPLETION_TIME: Int
    let MAX_COMPLETION_TIME: Int
}

// MARK: - Resource Utilization

struct ResourceUtilizationDto: Decodable {
    let resourceId: String
    let resourceType: String
    let city: String
    let capacity: Int
    let used: Int
    let percentage: Int
    let status: String
}

// MARK: - City Resource

struct CityResourceDto: Decodable {
    let total: Int
    let used: Int
    let available: Int
}

// MARK: - Recent Allocation

struct RecentAllocationDto: Decodable {
    let id: String
    let requestId: String
    let resourceId: String
    let priorityScore: Int
    let status: String
    let timestamp: Date
    let expectedCompletionAt: Date?
    let completedAt: Date?
    let request: RecentAllocationRequestDto
    let resource: RecentAllocationResourceDto
    let progress: Int
    let remainingSeconds: Int
    let totalDurationSeconds: Int?
}

struct RecentAllocationRequestDto: Decodable {
    let id: String
    let userId: String
    let service: String
    let requestType: String
    let urgency: String
    let status: String
    let createdAt: Date
    let queuedAt: Date?
    let processedAt: Date?
    let user: DashboardUserDto
}

struct RecentAllocationResourceDto: Decodable {
    let id: String
    let resourceType: String
    let capacity: Int
    let city: String
    let status: String
}

// MARK: - Dashboard User DTO (ayrı tanım, isim çakışmasını önlemek için)

struct DashboardUserDto: Decodable {
    let id: String
    let name: String
    let email: String
    let password: String?
    let city: String
    let role: String
}

// MARK: - Recent Log

struct RecentLogDto: Decodable {
    let id: String
    let eventType: String
    let eventData: EventDataDto
    let entityType: String
    let entityId: String
    let timestamp: Date
    let metadata: LogMetadataDto?
}

struct EventDataDto: Decodable {
    let message: String?
    let details: EventDetailsDto?
    let channel: String?
    let service: String?
    let user_id: String?
    let user_name: String?
    let request_type: String?
}

struct EventDetailsDto: Decodable {
    let reason: String?
    let priorityScore: Int?
    let requestId: String?
    let resourceId: String?
    let durationSeconds: Int?
    let city: String?
    let resourceType: String?
    let userId: String?
    let service: String?
    let urgency: String?
    let requestType: String?
}

struct LogMetadataDto: Decodable {
    let processingTime: Int?
    let duration: Int?
}

// MARK: - Priority Queue Item

struct PriorityQueueItemDto: Decodable {
    let id: String
    let userId: String
    let service: String
    let requestType: String
    let urgency: String
    let status: String
    let createdAt: Date
    let queuedAt: Date?
    let processedAt: Date?
    let user: DashboardUserDto
    let priorityScore: Int
}

// MARK: - Breakdown

struct BreakdownDto: Decodable {
    let byUrgency: [UrgencyBreakdownDto]
    let byService: [ServiceBreakdownDto]
}

struct UrgencyBreakdownDto: Decodable {
    let _count: CountDto
    let urgency: String
}

struct ServiceBreakdownDto: Decodable {
    let _count: CountDto
    let service: String
}

struct CountDto: Decodable {
    let id: Int
}
