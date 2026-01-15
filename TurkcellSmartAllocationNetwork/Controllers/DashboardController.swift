//
//  DashboardController.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Protocol

protocol DashboardControllerProtocol {
    func getSummary(from url: URL) async throws -> DashboardSummaryDto
}

// MARK: - Controller Implementation

final class DashboardController: DashboardControllerProtocol {

    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = DashboardController.makeDecoder()) {
        self.decoder = decoder
    }

    convenience init() {
        self.init(decoder: DashboardController.makeDecoder())
    }

    /// Dashboard Summary endpoint'inden veri çeker
    func getSummary(from url: URL) async throws -> DashboardSummaryDto {
        print("\n" + String(repeating: "─", count: 60))
        print("📡 [DashboardController] Dashboard Summary endpoint'ine istek atılıyor...")
        print("🔗 URL: \(url.absoluteString)")
        print(String(repeating: "─", count: 60))
        
        let startTime = Date()
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AppError.server(status: httpResponse.statusCode, message: nil)
            }
            
            let result = try decoder.decode(DashboardSummaryDto.self, from: data)
            
            let elapsed = Date().timeIntervalSince(startTime)
            
            print("✅ [DashboardController] Veri başarıyla alındı")
            print("⏱️  [DashboardController] İstek süresi: \(String(format: "%.2f", elapsed)) saniye")
            print("📊 [DashboardController] Stats: Bekleyen=\(result.stats.pendingRequests), Aktif=\(result.stats.activeAllocations), Tamamlanan=\(result.stats.completedAllocations)")
            print(String(repeating: "─", count: 60) + "\n")
            
            return result
        } catch let decodingError as DecodingError {
            print("❌ [DashboardController] Decoding hatası: \(decodingError)")
            throw AppError.decoding
        } catch {
            print("❌ [DashboardController] Hata oluştu: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - JSON Decoder Configuration

extension DashboardController {
    
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
