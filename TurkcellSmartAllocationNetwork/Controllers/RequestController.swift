//
//  RequestController.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import Foundation
import Alamofire

// MARK: - Protocol

protocol RequestControllerProtocol {
    func get<T: Decodable>(_ url: URL) async throws -> T
    func getRequests(from url: URL) async throws -> [RequestDto]
}

// MARK: - Controller Implementation

final class RequestController: RequestControllerProtocol {

    private let session: Session
    private let decoder: JSONDecoder

    init(session: Session = .default, decoder: JSONDecoder = RequestController.makeDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    convenience init() {
        self.init(session: .default, decoder: RequestController.makeDecoder())
    }

    /// Generic GET request
    func get<T: Decodable>(_ url: URL) async throws -> T {
        print("🌐 [RequestController] GET isteği gönderiliyor: \(url.absoluteString)")
        
        do {
            let result = try await session
                .request(url, method: .get)
                .validate()
                .serializingDecodable(T.self, decoder: decoder)
                .value
            
            print("✅ [RequestController] Veri başarıyla alındı")
            return result
        } catch {
            print("❌ [RequestController] Hata oluştu: \(error.localizedDescription)")
            
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
    
    /// Request listesi için özel metod
    func getRequests(from url: URL) async throws -> [RequestDto] {
        print("\n" + String(repeating: "─", count: 60))
        print("📡 [RequestController] Requests endpoint'ine istek atılıyor...")
        print("🔗 URL: \(url.absoluteString)")
        print(String(repeating: "─", count: 60))
        
        let startTime = Date()
        let requests: [RequestDto] = try await get(url)
        let elapsed = Date().timeIntervalSince(startTime)
        
        print("⏱️  [RequestController] İstek süresi: \(String(format: "%.2f", elapsed)) saniye")
        print("📊 [RequestController] Toplam \(requests.count) adet request alındı")
        print(String(repeating: "─", count: 60) + "\n")
        
        return requests
    }
}

// MARK: - JSON Decoder Configuration

extension RequestController {
    
    /// ISO8601 tarih formatını destekleyen decoder oluşturur
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
