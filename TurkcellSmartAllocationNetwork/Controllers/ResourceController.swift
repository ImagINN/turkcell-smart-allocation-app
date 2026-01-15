//
//  ResourceController.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation
import Alamofire

// MARK: - Protocol

protocol ResourceControllerProtocol {
    func get<T: Decodable>(_ url: URL) async throws -> T
    func getResources(from url: URL) async throws -> [ResourceFullDto]
}

// MARK: - Controller Implementation

final class ResourceController: ResourceControllerProtocol {

    private let session: Session
    private let decoder: JSONDecoder

    init(session: Session = .default, decoder: JSONDecoder = ResourceController.makeDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    convenience init() {
        self.init(session: .default, decoder: ResourceController.makeDecoder())
    }

    /// Generic GET request
    func get<T: Decodable>(_ url: URL) async throws -> T {
        print("🌐 [ResourceController] GET isteği gönderiliyor: \(url.absoluteString)")
        
        do {
            let result = try await session
                .request(url, method: .get)
                .validate()
                .serializingDecodable(T.self, decoder: decoder)
                .value
            
            print("✅ [ResourceController] Veri başarıyla alındı")
            return result
        } catch {
            print("❌ [ResourceController] Hata oluştu: \(error.localizedDescription)")
            
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
    
    /// Resource listesi için özel metod
    func getResources(from url: URL) async throws -> [ResourceFullDto] {
        print("\n" + String(repeating: "─", count: 60))
        print("📡 [ResourceController] Resources endpoint'ine istek atılıyor...")
        print("🔗 URL: \(url.absoluteString)")
        print(String(repeating: "─", count: 60))
        
        let startTime = Date()
        let resources: [ResourceFullDto] = try await get(url)
        let elapsed = Date().timeIntervalSince(startTime)
        
        print("⏱️  [ResourceController] İstek süresi: \(String(format: "%.2f", elapsed)) saniye")
        print("📊 [ResourceController] Toplam \(resources.count) adet resource alındı")
        print(String(repeating: "─", count: 60) + "\n")
        
        return resources
    }
}

// MARK: - JSON Decoder Configuration

extension ResourceController {
    
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
