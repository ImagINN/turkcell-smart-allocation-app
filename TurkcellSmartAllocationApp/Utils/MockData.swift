//
//  MockData.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 14.01.2026.
//

import SwiftUI

enum Urgency: String, Codable {
    case low = "LOW"
    case medium = "ORTA"
    case high = "HIGH"
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

enum RequestStatus: String, Codable {
    case pending = "PENDING"
    case assigned = "ASSIGNED"
    case completed = "COMPLETED"
}

enum ResourceStatusMock: String, Codable {
    case available = "AVAILABLE"
    case busy = "BUSY"
    
    var displayName: String {
        self == .available ? "Müsait" : "Meşgul"
    }
    
    var color: Color {
        self == .available ? .green : .gray
    }
}

struct RequestMock: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let service: String
    let location: String
    let urgency: Urgency
    let priorityScore: Int
    let waitingTime: String
    let addTime: Date
    let status: RequestStatus
}

struct ResourceMock: Identifiable {
    let id: String
    let type: String
    let capacity: Int
    let city: String
    let status: ResourceStatusMock
}

struct AllocationMock: Identifiable {
    let id: String
    let request: RequestMock
    let resource: ResourceMock
    let timestamp: String
}
