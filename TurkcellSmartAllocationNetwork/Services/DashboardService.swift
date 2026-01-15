//
//  DashboardService.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 15.01.2026.
//

import Foundation

// MARK: - Service Protocol

protocol DashboardServiceProtocol {
    func fetchSummary() async throws -> DashboardSummaryDto
}

// MARK: - Service Implementation

final class DashboardService: DashboardServiceProtocol {

    private let controller: DashboardControllerProtocol

    init(controller: DashboardControllerProtocol? = nil) {
        if let controller {
            self.controller = controller
        } else {
            self.controller = DashboardController()
        }
    }

    /// Dashboard summary verisini getirir ve konsola basar
    func fetchSummary() async throws -> DashboardSummaryDto {
        let url = EndpointURLHandler.dashboardSummary.url
        let summary = try await controller.getSummary(from: url)
        
        // Konsola veriyi bas
        printSummary(summary)
        
        return summary
    }
}

// MARK: - Console Logging

private extension DashboardService {
    
    func printSummary(_ summary: DashboardSummaryDto) {
        print("\n" + String(repeating: "=", count: 80))
        print("📊 DASHBOARD SUMMARY")
        print(String(repeating: "=", count: 80))
        
        // Stats
        print("\n📈 İSTATİSTİKLER:")
        print("    🕐 Bekleyen Talepler: \(summary.stats.pendingRequests)")
        print("    🔵 Aktif Atamalar: \(summary.stats.activeAllocations)")
        print("    ✅ Tamamlanan Atamalar: \(summary.stats.completedAllocations)")
        print("    🏢 Toplam Kaynak: \(summary.stats.totalResources)")
        print("    📅 Bugün Tamamlanan: \(summary.stats.todayCompleted)")
        print("    📋 Kuyrukta Bekleyen: \(summary.stats.queuedRequests)")
        
        // Automation Status
        print("\n🤖 OTOMASYON DURUMU:")
        print("    Durum: \(summary.automationStatus.isRunning ? "✅ Çalışıyor" : "⏸️ Durdu")")
        print("    Request Interval: \(summary.automationStatus.config.REQUEST_INTERVAL)ms")
        print("    Allocation Interval: \(summary.automationStatus.config.ALLOCATION_INTERVAL)ms")
        
        // Resource Utilization
        print("\n🏢 KAYNAK KULLANIMI:")
        for resource in summary.resourceUtilization {
            let statusEmoji = resource.status == "AVAILABLE" ? "🟢" : "🔴"
            print("    \(statusEmoji) \(resource.resourceId) (\(resource.city)): %\(resource.percentage) kullanım (\(resource.used)/\(resource.capacity))")
        }
        
        // Priority Queue
        print("\n📋 ÖNCELİK KUYRUĞU (\(summary.priorityQueue.count) talep):")
        for (index, item) in summary.priorityQueue.prefix(5).enumerated() {
            print("    [\(index + 1)] \(item.user.name) - \(item.service) - \(item.requestType) (Skor: \(item.priorityScore))")
        }
        
        // Recent Allocations
        print("\n🔗 SON ATAMALAR (\(summary.recentAllocations.count) adet):")
        for allocation in summary.recentAllocations.prefix(5) {
            let statusEmoji = allocation.status == "COMPLETED" ? "✅" : "🔵"
            print("    \(statusEmoji) \(allocation.request.user.name) → \(allocation.resourceId) (%\(allocation.progress) ilerleme)")
        }
        
        // Breakdown
        print("\n📊 DAĞILIM:")
        print("    Aciliyete Göre:")
        for urgency in summary.breakdown.byUrgency {
            let emoji = urgency.urgency == "HIGH" ? "🔴" : (urgency.urgency == "MEDIUM" ? "🟠" : "🟢")
            print("      \(emoji) \(urgency.urgency): \(urgency._count.id) adet")
        }
        print("    Servise Göre:")
        for service in summary.breakdown.byService {
            print("      📱 \(service.service): \(service._count.id) adet")
        }
        
        print("\n" + String(repeating: "=", count: 80) + "\n")
    }
}
