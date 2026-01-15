//
//  RequestService.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Service Protocol

protocol RequestServiceProtocol {
    func fetchRequests() async throws -> [RequestDto]
    func fetchRequestDetail(id: String) async throws -> RequestDto
    func fetchRequests(for userId: String) async throws -> [RequestDto]
}

// MARK: - Service Implementation

final class RequestService: RequestServiceProtocol {

    private let controller: RequestControllerProtocol

    init(controller: RequestControllerProtocol? = nil) {
        if let controller {
            self.controller = controller
        } else {
            self.controller = RequestController()
        }
    }

    /// Tüm request'leri getirir ve konsola basar
    func fetchRequests() async throws -> [RequestDto] {
        let url = EndpointURLHandler.requests.url
        let requests = try await controller.getRequests(from: url)
        
        // Konsola veriyi bas
        printRequests(requests)
        
        return requests
    }

    /// Belirli bir request'in detayını getirir
    func fetchRequestDetail(id: String) async throws -> RequestDto {
        let url = EndpointURLHandler.requestDetail(id: id).url
        let request: RequestDto = try await controller.get(url)
        
        // Konsola veriyi bas
        printRequestDetail(request)
        
        return request
    }

    /// Kullanıcıya ait request'leri getirir
    func fetchRequests(for userId: String) async throws -> [RequestDto] {
        let url = EndpointURLHandler.userRequests(userId: userId).url
        let requests: [RequestDto] = try await controller.get(url)
        
        // Konsola veriyi bas
        printRequests(requests)
        
        return requests
    }
}

// MARK: - Console Logging

private extension RequestService {
    
    func printRequests(_ requests: [RequestDto]) {
        print("\n" + String(repeating: "=", count: 80))
        print("📋 REQUESTS - Toplam: \(requests.count) adet")
        print(String(repeating: "=", count: 80))
        
        for (index, request) in requests.enumerated() {
            print("\n[\(index + 1)] Request ID: \(request.id)")
            print("    👤 Kullanıcı: \(request.user.name) (\(request.userId))")
            print("    📧 Email: \(request.user.email)")
            print("    🏙️  Şehir: \(request.user.city)")
            print("    🔧 Servis: \(request.service)")
            print("    📝 Tip: \(request.requestType)")
            print("    ⚡ Aciliyet: \(request.urgency)")
            print("    📊 Durum: \(request.status)")
            print("    🎯 Öncelik Skoru: \(request.priorityScore)")
            print("    📅 Oluşturulma: \(formatDate(request.createdAt))")
            
            if let queuedAt = request.queuedAt {
                print("    ⏳ Kuyruğa Alınma: \(formatDate(queuedAt))")
            }
            
            if let processedAt = request.processedAt {
                print("    ✅ İşlenme: \(formatDate(processedAt))")
            }
            
            if let allocation = request.allocation {
                print("    🔗 Atama:")
                print("       - Kaynak ID: \(allocation.resourceId)")
                print("       - Kaynak Tipi: \(allocation.resource.resourceType)")
                print("       - Kaynak Şehri: \(allocation.resource.city)")
                print("       - Kapasite: \(allocation.resource.capacity)")
                print("       - Atama Durumu: \(allocation.status)")
                print("       - Atama Skoru: \(allocation.priorityScore)")
                
                if let expectedAt = allocation.expectedCompletionAt {
                    print("       - Beklenen Tamamlanma: \(formatDate(expectedAt))")
                }
                
                if let completedAt = allocation.completedAt {
                    print("       - Tamamlanma: \(formatDate(completedAt))")
                }
            }
            
            print("    " + String(repeating: "-", count: 60))
        }
        
        print("\n" + String(repeating: "=", count: 80) + "\n")
    }
    
    func printRequestDetail(_ request: RequestDto) {
        print("\n" + String(repeating: "=", count: 80))
        print("📋 REQUEST DETAY")
        print(String(repeating: "=", count: 80))
        
        print("\n🆔 Request ID: \(request.id)")
        print("👤 Kullanıcı: \(request.user.name) (\(request.userId))")
        print("📧 Email: \(request.user.email)")
        print("🏙️  Şehir: \(request.user.city)")
        print("🔧 Servis: \(request.service)")
        print("📝 Tip: \(request.requestType)")
        print("⚡ Aciliyet: \(request.urgency)")
        print("📊 Durum: \(request.status)")
        print("🎯 Öncelik Skoru: \(request.priorityScore)")
        print("📅 Oluşturulma: \(formatDate(request.createdAt))")
        
        if let queuedAt = request.queuedAt {
            print("⏳ Kuyruğa Alınma: \(formatDate(queuedAt))")
        }
        
        if let processedAt = request.processedAt {
            print("✅ İşlenme: \(formatDate(processedAt))")
        }
        
        if let allocation = request.allocation {
            print("\n🔗 ATAMA BİLGİLERİ:")
            print("   Atama ID: \(allocation.id)")
            print("   Kaynak ID: \(allocation.resourceId)")
            print("   Kaynak Tipi: \(allocation.resource.resourceType)")
            print("   Kaynak Şehri: \(allocation.resource.city)")
            print("   Kapasite: \(allocation.resource.capacity)")
            print("   Kaynak Durumu: \(allocation.resource.status)")
            print("   Atama Durumu: \(allocation.status)")
            print("   Atama Skoru: \(allocation.priorityScore)")
            print("   Atama Zamanı: \(formatDate(allocation.timestamp))")
            
            if let expectedAt = allocation.expectedCompletionAt {
                print("   Beklenen Tamamlanma: \(formatDate(expectedAt))")
            }
            
            if let completedAt = allocation.completedAt {
                print("   Tamamlanma: \(formatDate(completedAt))")
            }
        }
        
        print("\n" + String(repeating: "=", count: 80) + "\n")
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return formatter.string(from: date)
    }
}
