//
//  RequestService.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Endpoint

enum APIEndpoint {
    case requests
    case requestDetail(id: String)
    case userRequests(userId: String)

    func url(baseURL: URL) -> URL {
        switch self {
        case .requests:
            return baseURL.appendingPathComponent("requests")

        case .requestDetail(let id):
            return baseURL
                .appendingPathComponent("requests")
                .appendingPathComponent(id)

        case .userRequests(let userId):
            var components = URLComponents(url: baseURL.appendingPathComponent("requests"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "userId", value: userId)
            ]
            return components?.url ?? baseURL.appendingPathComponent("requests")
        }
    }
}

// MARK: - Service

protocol RequestServiceProtocol {
    func fetchRequests() async throws -> [RequestDto]
    func fetchRequestDetail(id: String) async throws -> RequestDto
    func fetchRequests(for userId: String) async throws -> [RequestDto]

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class RequestService: RequestServiceProtocol {

    private let controller: RequestControllerProtocol
    private let baseURL: URL

    init(
        baseURL: URL,
        controller: RequestControllerProtocol? = nil
    ) {
        self.baseURL = baseURL
        if let controller {
            self.controller = controller
        } else {
            self.controller = RequestController()
        }
    }

    func fetchRequests() async throws -> [RequestDto] {
        let url = APIEndpoint.requests.url(baseURL: baseURL)
        return try await controller.getRequests(from: url)
    }

    func fetchRequestDetail(id: String) async throws -> RequestDto {
        let url = APIEndpoint.requestDetail(id: id).url(baseURL: baseURL)
        return try await controller.get(url)
    }

    func fetchRequests(for userId: String) async throws -> [RequestDto] {
        let url = APIEndpoint.userRequests(userId: userId).url(baseURL: baseURL)
        return try await controller.get(url)
    }

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = endpoint.url(baseURL: baseURL)
        return try await controller.get(url)
    }
}
