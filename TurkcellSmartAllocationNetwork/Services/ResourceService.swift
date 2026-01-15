//
//  ResourceService.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Service Protocol

protocol ResourceServiceProtocol {
    func fetchResources() async throws -> [ResourceFullDto]
    func fetchResources(filter: ResourceFilterParams) async throws -> [ResourceFullDto]
    func fetchResources(city: String?, status: ResourceStatus?) async throws -> [ResourceFullDto]
}

// MARK: - Service Implementation

final class ResourceService: ResourceServiceProtocol {

    private let controller: ResourceControllerProtocol

    init(controller: ResourceControllerProtocol? = nil) {
        if let controller {
            self.controller = controller
        } else {
            self.controller = ResourceController()
        }
    }

    /// Tüm resource'ları getirir ve konsola basar
    func fetchResources() async throws -> [ResourceFullDto] {
        let url = EndpointURLHandler.resources.url
        let resources = try await controller.getResources(from: url)
        
        // Konsola veriyi bas
        printResources(resources)
        
        return resources
    }
    
    /// Filtrelenmiş resource'ları getirir
    func fetchResources(filter: ResourceFilterParams) async throws -> [ResourceFullDto] {
        let url = EndpointURLHandler.resourcesFiltered(city: filter.city, status: filter.status?.rawValue).url
        let resources = try await controller.getResources(from: url)
        
        // Konsola veriyi bas
        printResources(resources, filter: filter)
        
        return resources
    }
    
    /// Şehir ve/veya status'e göre filtrelenmiş resource'ları getirir
    func fetchResources(city: String?, status: ResourceStatus?) async throws -> [ResourceFullDto] {
        let filter = ResourceFilterParams(city: city, status: status)
        return try await fetchResources(filter: filter)
    }
}

// MARK: - Console Logging

private extension ResourceService {
    
    func printResources(_ resources: [ResourceFullDto], filter: ResourceFilterParams? = nil) {
        print("\n" + String(repeating: "=", count: 80))
        print("🏢 RESOURCES - Toplam: \(resources.count) adet kaynak")
        
        if let filter = filter {
            var filterInfo: [String] = []
            if let city = filter.city { filterInfo.append("Şehir: \(city)") }
            if let status = filter.status { filterInfo.append("Durum: \(status.displayName)") }
            if !filterInfo.isEmpty {
                print("🔍 Filtre: \(filterInfo.joined(separator: ", "))")
            }
        }
        
        print(String(repeating: "=", count: 80))
        
        for (index, resource) in resources.enumerated() {
            print("\n[\(index + 1)] Resource ID: \(resource.id)")
            print("    🏷️  Tip: \(resource.resourceType)")
            print("    🏙️  Şehir: \(resource.city)")
            print("    📊 Kapasite: \(resource.capacity)")
            print("    📈 Kullanım: %\(resource.utilization)")
            print("    🔵 Aktif Atama: \(resource.activeAllocations)")
            print("    📍 Durum: \(resource.status.displayName) (\(resource.status.rawValue))")
            
            if !resource.allocations.isEmpty {
                print("\n    📋 ATAMALAR (\(resource.allocations.count) adet):")
                
                for (allocIndex, allocation) in resource.allocations.enumerated() {
                    print("       [\(allocIndex + 1)] Atama ID: \(allocation.id)")
                    print("           Request ID: \(allocation.requestId)")
                    print("           👤 Kullanıcı: \(allocation.request.user.name)")
                    print("           📧 Email: \(allocation.request.user.email)")
                    print("           🏙️  Kullanıcı Şehri: \(allocation.request.user.city)")
                    print("           🔧 Servis: \(allocation.request.service)")
                    print("           📝 Tip: \(allocation.request.requestType)")
                    print("           ⚡ Aciliyet: \(allocation.request.urgency)")
                    print("           📊 Durum: \(allocation.request.status)")
                    print("           🎯 Öncelik Skoru: \(allocation.priorityScore)")
                    print("           📅 Atama Zamanı: \(formatDate(allocation.timestamp))")
                    
                    if let expectedAt = allocation.expectedCompletionAt {
                        print("           ⏳ Beklenen Tamamlanma: \(formatDate(expectedAt))")
                    }
                    
                    if let completedAt = allocation.completedAt {
                        print("           ✅ Tamamlanma: \(formatDate(completedAt))")
                    }
                }
            } else {
                print("    📋 ATAMALAR: Aktif atama yok")
            }
            
            print("    " + String(repeating: "-", count: 60))
        }
        
        // Özet bilgiler
        let availableCount = resources.filter { $0.status == .available }.count
        let busyCount = resources.filter { $0.status == .busy }.count
        let totalAllocations = resources.reduce(0) { $0 + $1.activeAllocations }
        let avgUtilization = resources.isEmpty ? 0 : resources.reduce(0) { $0 + $1.utilization } / resources.count
        
        print("\n📈 ÖZET:")
        print("    ✅ Müsait Kaynak: \(availableCount)")
        print("    🔴 Meşgul Kaynak: \(busyCount)")
        print("    📊 Toplam Aktif Atama: \(totalAllocations)")
        print("    📈 Ortalama Kullanım: %\(avgUtilization)")
        
        print("\n" + String(repeating: "=", count: 80) + "\n")
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return formatter.string(from: date)
    }
}
