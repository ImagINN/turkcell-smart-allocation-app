//
//  Decoders.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import Foundation
import Alamofire

public struct APIErrorBody: Decodable {
    public let title: String?
    public let message: String?
    public let resolution: String?
}

public enum AppError: Error {
    case networkNoInternet
    case networkTimeout
    case cancelled
    case server(status: Int, message: String?)
    case decoding
    case invalidResponse
    case noResults(title: String?, message: String?, resolution: String?)
    case unknown(Error?)
}

public extension AppError {
    var userMessage: String {
        switch self {
        case .networkNoInternet:
            return "No internet connection. Please check your network and try again."
        case .networkTimeout:
            return "The request timed out. Please try again later."
        case .cancelled:
            return "The request was cancelled."
        case .server(_, let message):
            return message ?? "A server error occurred. Please try again."
        case .decoding:
            return "There was a problem reading the server response."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .noResults(_, let message, _):
            return message ?? "No definitions found for this word."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

public enum ErrorHandler {
    public static func map(
        error: Error?,
        response: HTTPURLResponse?,
        data: Data?
    ) -> AppError {
        if let http = response, !(200..<300).contains(http.statusCode) {
            if let body = decodeErrorBody(from: data) {
                if http.statusCode == 404 || isNoDefinition(body: body) {
                    return .noResults(title: body.title, message: body.message, resolution: body.resolution)
                }
                return .server(status: http.statusCode, message: body.message ?? body.title)
            }
            return .server(status: http.statusCode, message: nil)
        }

        if let error = error {
            if let afError = error as? AFError {
                switch afError {
                case .explicitlyCancelled:
                    return .cancelled

                case .sessionTaskFailed(let underlying as URLError):
                    return mapURLError(underlying)

                case .responseSerializationFailed(let reason):
                    if case .decodingFailed = reason,
                       let body = decodeErrorBody(from: data),
                       isNoDefinition(body: body) {
                        return .noResults(title: body.title, message: body.message, resolution: body.resolution)
                    }
                    return .decoding

                default:
                    return .unknown(afError)
                }
            } else if let urlErr = error as? URLError {
                return mapURLError(urlErr)
            } else if error is DecodingError {
                if let body = decodeErrorBody(from: data), isNoDefinition(body: body) {
                    return .noResults(title: body.title, message: body.message, resolution: body.resolution)
                }
                return .decoding
            } else {
                return .unknown(error)
            }
        }

        return .invalidResponse
    }

    private static func mapURLError(_ e: URLError) -> AppError {
        switch e.code {
        case .notConnectedToInternet: return .networkNoInternet
        case .timedOut: return .networkTimeout
        case .cancelled: return .cancelled
        default: return .unknown(e)
        }
    }

    // MARK: - Helpers

    private static func decodeErrorBody(from data: Data?) -> APIErrorBody? {
        guard let data else { return nil }
        if let dto = try? JSONDecoder().decode(ApiErrorDto.self, from: data) {
            return APIErrorBody(title: dto.title, message: dto.message, resolution: dto.resolution)
        }
        if let body = try? JSONDecoder().decode(APIErrorBody.self, from: data) {
            return body
        }
        return nil
    }

    private static func isNoDefinition(body: APIErrorBody) -> Bool {
        if let t = body.title, t.caseInsensitiveCompare("No Definitions Found") == .orderedSame {
            return true
        }
        return false
    }
}
