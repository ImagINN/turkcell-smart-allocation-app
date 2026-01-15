//
//  DashboardView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct DashboardView: View {
    @Binding var selectedTab: Int
    
    // MARK: - State Properties
    
    @State private var summary: DashboardSummaryDto?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // MARK: - Services
    
    private let dashboardService = DashboardService()
    
    // MARK: - Computed Properties
    
    private var stats: DashboardStatsDto? {
        summary?.stats
    }
    
    private var priorityQueue: [PriorityQueueItemDto] {
        summary?.priorityQueue ?? []
    }
    
    private var recentAllocations: [RecentAllocationDto] {
        Array((summary?.recentAllocations ?? []).prefix(5))
    }
    
    private var resourceUtilization: [ResourceUtilizationDto] {
        summary?.resourceUtilization ?? []
    }
    
    private var automationRunning: Bool {
        summary?.automationStatus.isRunning ?? false
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Turkcell Smart Allocation")
                        .font(.title)
                        .fontWeight(.black)
                    Spacer()
                    
                    // Automation Status Indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(automationRunning ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(automationRunning ? "Aktif" : "Durdu")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Image(systemName: "bell.badge")
                }
                .padding(.horizontal)
                
                // Stats Cards
                if let stats = stats {
                    HStack(spacing: 12) {
                        SummaryMetricCard(title: "Bekleyen Talep", value: stats.pendingRequests, valueColor: .blue)
                            .onTapGesture { selectedTab = 1 }
                        SummaryMetricCard(title: "Aktif Atama", value: stats.activeAllocations, valueColor: .orange)
                            .onTapGesture { selectedTab = 3 }
                        SummaryMetricCard(title: "Bugün Tamamlanan", value: stats.todayCompleted, valueColor: .green)
                            .onTapGesture { selectedTab = 3 }
                    }
                    .padding(.horizontal)
                }
                
                if isLoading {
                    ProgressView("Veriler yükleniyor...")
                        .padding(.vertical, 40)
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Tekrar Dene") {
                            Task { await fetchDashboard() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    // Resource Utilization
                    if !resourceUtilization.isEmpty {
                        VStack(spacing: 15) {
                            SectionHeader(title: "Kaynak Kullanımı") { selectedTab = 2 }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(resourceUtilization, id: \.resourceId) { resource in
                                        ResourceUtilizationCard(resource: resource)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Priority Queue (Kritik Talepler)
                    VStack(spacing: 15) {
                        SectionHeader(title: "Öncelik Kuyruğu") { selectedTab = 1 }
                        
                        if priorityQueue.isEmpty {
                            EmptyStateView(message: "Kuyrukta talep yok", icon: "checkmark.circle")
                                .padding(.horizontal)
                        } else {
                            ForEach(priorityQueue.prefix(3), id: \.id) { item in
                                PriorityQueueCard(item: item)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Recent Allocations (Aktif İşlemler)
                    VStack(spacing: 15) {
                        SectionHeader(title: "Son Atamalar") { selectedTab = 3 }
                        
                        if recentAllocations.isEmpty {
                            EmptyStateView(message: "Aktif işlem bulunmuyor", icon: "clock")
                                .padding(.horizontal)
                        } else {
                            ForEach(recentAllocations, id: \.id) { allocation in
                                RecentAllocationCard(allocation: allocation)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
        .refreshable {
            await fetchDashboard()
        }
        .task {
            await fetchDashboard()
        }
    }
    
    // MARK: - Methods
    
    private func fetchDashboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            summary = try await dashboardService.fetchSummary()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [DashboardView] Veri çekme hatası: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Resource Utilization Card

struct ResourceUtilizationCard: View {
    let resource: ResourceUtilizationDto
    
    private var statusColor: Color {
        if resource.percentage >= 100 { return .red }
        if resource.percentage >= 75 { return .orange }
        return .green
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(resource.resourceId)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(resource.status == "AVAILABLE" ? "Müsait" : "Dolu")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundColor(.red)
                Text(resource.city)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Kullanım")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(resource.used)/\(resource.capacity)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(statusColor)
                            .frame(width: geometry.size.width * CGFloat(min(resource.percentage, 100)) / 100, height: 8)
                    }
                }
                .frame(height: 8)
                
                Text("%\(resource.percentage)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .frame(width: 160)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Priority Queue Card

struct PriorityQueueCard: View {
    let item: PriorityQueueItemDto
    
    private var urgencyColor: Color {
        switch item.urgency {
        case "HIGH": return .red
        case "MEDIUM": return .orange
        case "LOW": return .blue
        default: return .gray
        }
    }
    
    private var waitingTime: String {
        let interval = Date().timeIntervalSince(item.createdAt)
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return String(format: "%d saat %d dk", hours, remainingMinutes)
        } else {
            return String(format: "%d dk", remainingMinutes)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.user.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(item.urgency)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(urgencyColor.opacity(0.2))
                    .foregroundColor(urgencyColor)
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 10) {
                IconLabel(iconName: "network", text: item.service)
                IconLabel(iconName: "mappin.and.ellipse", text: item.user.city)
            }
            
            HStack(spacing: 15) {
                MetricBox(title: "Öncelik Skoru", value: "\(item.priorityScore)/100", showProgress: true, progressValue: Double(item.priorityScore), iconName: nil)
                MetricBox(title: "Bekleme Süresi", value: waitingTime, showProgress: false, progressValue: 0, iconName: "clock.fill")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Recent Allocation Card

struct RecentAllocationCard: View {
    let allocation: RecentAllocationDto
    
    private var statusColor: Color {
        allocation.status == "COMPLETED" ? .green : .teal
    }
    
    private var statusText: String {
        allocation.status == "COMPLETED" ? "TAMAMLANDI" : "İŞLEMDE"
    }
    
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return formatter.string(from: allocation.timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(allocation.request.id.prefix(15) + "...")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text(allocation.request.user.name)
                        .font(.headline)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(statusText)
                        .font(.caption2)
                        .fontWeight(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                    
                    if allocation.status != "COMPLETED" {
                        Text("%\(allocation.progress)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.teal)
                    }
                }
            }
            
            // Progress Bar (sadece aktif için)
            if allocation.status != "COMPLETED" {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.teal)
                            .frame(width: geometry.size.width * CGFloat(allocation.progress) / 100, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text("ATANAN EKİP")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(allocation.resourceId)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("LOKASYON")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(allocation.resource.city)
                        .font(.subheadline)
                }
            }
            
            HStack {
                Label("\(formattedTimestamp) Atandı", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                if allocation.remainingSeconds > 0 {
                    Text("\(allocation.remainingSeconds) sn kaldı")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Text("Skor: \(allocation.priorityScore)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let message: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}
