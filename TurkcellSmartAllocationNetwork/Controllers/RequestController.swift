//
//  RequestController.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import Foundation
import Alamofire

protocol RequestControllerProtocol {
    func get<T: Decodable>(_ url: URL) async throws -> T
    func getRequests(from url: URL) async throws -> [RequestDto]
}

final class RequestController: RequestControllerProtocol {

    private let session: Session
    private let decoder: JSONDecoder

    init(session: Session = .default, decoder: JSONDecoder = RequestController.makeDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    convenience init(configuration: URLSessionConfiguration = .af.default,
                     decoder: JSONDecoder = RequestController.makeDecoder()) {
        let session = Session(configuration: configuration)
        self.init(session: session, decoder: decoder)
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        do {
            return try await session
                .request(url, method: .get)
                .validate()
                .serializingDecodable(T.self, decoder: decoder)
                .value
        } catch {
            if let afError = error.asAFError {
                let appError = ErrorHandler.map(
                    error: afError,
                    response: afError.responseCode.flatMap { _ in nil },
                    data: nil
                )
                throw appError
            }
            throw error
        }
    }
    
    func getRequests(from url: URL) async throws -> [RequestDto] {
        try await get(url)
    }
}

// MARK: - Decoder

extension RequestController {
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        let isoWithMs = ISO8601DateFormatter()
        isoWithMs.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoNoMs = ISO8601DateFormatter()
        isoNoMs.formatOptions = [.withInternetDateTime]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            if let date = isoWithMs.date(from: raw) ?? isoNoMs.date(from: raw) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(raw)"
            )
        }

        return decoder
    }
}
