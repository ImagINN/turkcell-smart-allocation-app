//
//  AllocationController.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation
import Alamofire

// MARK: - Protocol

protocol AllocationControllerProtocol {
    func get<T: Decodable>(_ url: URL) async throws -> T
    func getAllocations(from url: URL) async throws -> [AllocationFullDto]
}

// MARK: - Controller Implementation

final class AllocationController: AllocationControllerProtocol {

    private let session: Session
    private let decoder: JSONDecoder

    init(session: Session = .default, decoder: JSONDecoder = AllocationController.makeDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    convenience init() {
        self.init(session: .default, decoder: AllocationController.makeDecoder())
    }

    /// Generic GET request
    func get<T: Decodable>(_ url: URL) async throws -> T {
        print("🌐 [AllocationController] GET isteği gönderiliyor: \(url.absoluteString)")
        
        do {
            let result = try await session
                .request(url, method: .get)
                .validate()
                .serializingDecodable(T.self, decoder: decoder)
                .value
            
            print("✅ [AllocationController] Veri başarıyla alındı")
            return result
        } catch {
            print("❌ [AllocationController] Hata oluştu: \(error.localizedDescription)")
            
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
    
    /// Allocation listesi için özel metod
    func getAllocations(from url: URL) async throws -> [AllocationFullDto] {
        print("\n" + String(repeating: "─", count: 60))
        print("📡 [AllocationController] Allocations endpoint'ine istek atılıyor...")
        print("🔗 URL: \(url.absoluteString)")
        print(String(repeating: "─", count: 60))
        
        let startTime = Date()
        let allocations: [AllocationFullDto] = try await get(url)
        let elapsed = Date().timeIntervalSince(startTime)
        
        print("⏱️  [AllocationController] İstek süresi: \(String(format: "%.2f", elapsed)) saniye")
        print("📊 [AllocationController] Toplam \(allocations.count) adet allocation alındı")
        print(String(repeating: "─", count: 60) + "\n")
        
        return allocations
    }
}

// MARK: - JSON Decoder Configuration

extension AllocationController {
    
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
