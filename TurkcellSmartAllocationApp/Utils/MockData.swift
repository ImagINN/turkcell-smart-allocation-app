//
//  MockData.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 14.01.2026.
//

import SwiftUI

enum Urgency: String, Codable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct RequestMock: Identifiable {
    let id: String // REQ-2041 [cite: 17]
    let userId: String // U8 [cite: 18]
    let service: String // Superonline [cite: 19]
    let location: String // Ankara [cite: 35, 50]
    let urgency: Urgency //[cite: 21]
    let priorityScore: Int // 92 [cite: 75]
    let waitingTime: String // "12:45"
}

enum ResourceStatus: String, Codable {
    case available = "AVAILABLE"
    case busy = "BUSY"
    
    var displayName: String {
        self == .available ? "Müsait" : "Meşgul"
    }
    
    var color: Color {
        self == .available ? .green : .gray
    }
}

struct ResourceMock: Identifiable {
    let id: String // RES-1
    let type: String // TECH_TEAM, SUPPORT
    let capacity: Int // 5
    let city: String // Ankara
    let status: ResourceStatus
}
