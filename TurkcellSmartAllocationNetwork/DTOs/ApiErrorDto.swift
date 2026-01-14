//
//  ApiErrorDto.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

public struct ApiErrorDto: Decodable, Error, Equatable {
    
    public let title: String
    public let message: String
    public let resolution: String
    
    public init(title: String, message: String, resolution: String) {
        self.title = title
        self.message = message
        self.resolution = resolution
    }
}
