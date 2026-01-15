//
//  AllocationService.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Service Protocol

protocol AllocationServiceProtocol {
    func fetchAllocations() async throws -> [AllocationFullDto]
    func fetchAllocations(filter: AllocationFilterParams) async throws -> [AllocationFullDto]
    func fetchAllocations(status: AllocationStatus?) async throws -> [AllocationFullDto]
    func fetchAssignedAllocations() async throws -> [AllocationFullDto]
    func fetchCompletedAllocations() async throws -> [AllocationFullDto]
}

// MARK: - Service Implementation

final class AllocationService: AllocationServiceProtocol {

    private let controller: AllocationControllerProtocol

    init(controller: AllocationControllerProtocol? = nil) {
        if let controller {
            self.controller = controller
        } else {
            self.controller = AllocationController()
        }
    }

    /// Tüm allocation'ları getirir ve konsola basar
    func fetchAllocations() async throws -> [AllocationFullDto] {
        let url = EndpointURLHandler.allocations.url
        let allocations = try await controller.getAllocations(from: url)
        
        // Konsola veriyi bas
        printAllocations(allocations)
        
        return allocations
    }
    
    /// Filtrelenmiş allocation'ları getirir
    func fetchAllocations(filter: AllocationFilterParams) async throws -> [AllocationFullDto] {
        let url = EndpointURLHandler.allocationsFiltered(status: filter.status?.rawValue).url
        let allocations = try await controller.getAllocations(from: url)
        
        // Konsola veriyi bas
        printAllocations(allocations, filter: filter)
        
        return allocations
    }
    
    /// Status'e göre filtrelenmiş allocation'ları getirir
    func fetchAllocations(status: AllocationStatus?) async throws -> [AllocationFullDto] {
        let filter = AllocationFilterParams(status: status)
        return try await fetchAllocations(filter: filter)
    }
    
    /// Sadece ASSIGNED durumundaki allocation'ları getirir
    func fetchAssignedAllocations() async throws -> [AllocationFullDto] {
        return try await fetchAllocations(status: .assigned)
    }
    
    /// Sadece COMPLETED durumundaki allocation'ları getirir
    func fetchCompletedAllocations() async throws -> [AllocationFullDto] {
        return try await fetchAllocations(status: .completed)
    }
}

// MARK: - Console Logging

private extension AllocationService {
    
    func printAllocations(_ allocations: [AllocationFullDto], filter: AllocationFilterParams? = nil) {
        print("\n" + String(repeating: "=", count: 80))
        print("🔗 ALLOCATIONS - Toplam: \(allocations.count) adet atama")
        
        if let filter = filter, let status = filter.status {
            print("🔍 Filtre: Durum = \(status.displayName) (\(status.rawValue))")
        }
        
        print(String(repeating: "=", count: 80))
        
        for (index, allocation) in allocations.enumerated() {
            print("\n[\(index + 1)] Allocation ID: \(allocation.id)")
            print("    📊 Durum: \(allocation.status.displayName) (\(allocation.status.rawValue))")
            print("    🎯 Öncelik Skoru: \(allocation.priorityScore)")
            print("    📅 Atama Zamanı: \(formatDate(allocation.timestamp))")
            
            if let expectedAt = allocation.expectedCompletionAt {
                print("    ⏳ Beklenen Tamamlanma: \(formatDate(expectedAt))")
            }
            
            if let completedAt = allocation.completedAt {
                print("    ✅ Tamamlanma: \(formatDate(completedAt))")
            }
            
            // Request bilgileri
            print("\n    📋 REQUEST BİLGİLERİ:")
            print("       Request ID: \(allocation.request.id)")
            print("       👤 Kullanıcı: \(allocation.request.user.name)")
            print("       📧 Email: \(allocation.request.user.email)")
            print("       🏙️  Kullanıcı Şehri: \(allocation.request.user.city)")
            print("       🔧 Servis: \(allocation.request.service)")
            print("       📝 Tip: \(allocation.request.requestType)")
            print("       ⚡ Aciliyet: \(allocation.request.urgency)")
            print("       📊 Request Durumu: \(allocation.request.status)")
            
            // Resource bilgileri
            print("\n    🏢 RESOURCE BİLGİLERİ:")
            print("       Resource ID: \(allocation.resource.id)")
            print("       🏷️  Tip: \(allocation.resource.resourceType)")
            print("       🏙️  Şehir: \(allocation.resource.city)")
            print("       📊 Kapasite: \(allocation.resource.capacity)")
            print("       📍 Durum: \(allocation.resource.status)")
            
            print("    " + String(repeating: "-", count: 60))
        }
        
        // Özet bilgiler
        let assignedCount = allocations.filter { $0.status == .assigned }.count
        let completedCount = allocations.filter { $0.status == .completed }.count
        let avgScore = allocations.isEmpty ? 0 : allocations.reduce(0) { $0 + $1.priorityScore } / allocations.count
        
        // Kaynak bazında dağılım
        let resourceGroups = Dictionary(grouping: allocations) { $0.resource.city }
        
        print("\n📈 ÖZET:")
        print("    🔵 Atandı (ASSIGNED): \(assignedCount)")
        print("    ✅ Tamamlandı (COMPLETED): \(completedCount)")
        print("    🎯 Ortalama Öncelik Skoru: \(avgScore)")
        
        print("\n📊 KAYNAK BAZINDA DAĞILIM:")
        for (city, cityAllocations) in resourceGroups.sorted(by: { $0.key < $1.key }) {
            let cityAssigned = cityAllocations.filter { $0.status == .assigned }.count
            let cityCompleted = cityAllocations.filter { $0.status == .completed }.count
            print("    \(city): \(cityAllocations.count) atama (🔵 \(cityAssigned) | ✅ \(cityCompleted))")
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
