//
//  RequestDto.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import Foundation

struct RequestDto: Decodable, Sendable {
    let id: String
    let userId: String
    let service: String
    let requestType: String
    let urgency: String
    let status: String
    let createdAt: Date
    let user: UserDto
    let priorityScore: Int
}

struct UserDto: Decodable, Sendable {
    let id: String
    let name: String
    let city: String
}
