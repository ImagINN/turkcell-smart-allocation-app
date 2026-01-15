//
//  RequestView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct PendingRequestView: View {
    
    // MARK: - State Properties
    
    @State private var requests: [RequestDto] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFilter: RequestFilter = .all
    @State private var selectedUrgency: String = "Tümü"
    
    // MARK: - Services
    
    private let requestService = RequestService()
    
    // MARK: - Filter Enums
    
    enum RequestFilter: String, CaseIterable {
        case all = "Tümü"
        case pending = "Bekleyen"
        case assigned = "Atandı"
        case completed = "Tamamlandı"
    }
    
    private let urgencyOptions = ["Tümü", "HIGH", "MEDIUM", "LOW"]
    
    // MARK: - Computed Properties
    
    private var filteredRequests: [RequestDto] {
        var result = requests
        
        // Status filtresi
        switch selectedFilter {
        case .all:
            break
        case .pending:
            result = result.filter { $0.status == "PENDING" }
        case .assigned:
            result = result.filter { $0.status == "ASSIGNED" }
        case .completed:
            result = result.filter { $0.status == "COMPLETED" }
        }
        
        // Urgency filtresi
        if selectedUrgency != "Tümü" {
            result = result.filter { $0.urgency == selectedUrgency }
        }
        
        // Öncelik skoruna göre sırala
        return result.sorted { $0.priorityScore > $1.priorityScore }
    }
    
    private var pendingCount: Int {
        requests.filter { $0.status == "PENDING" }.count
    }
    
    private var highUrgencyCount: Int {
        requests.filter { $0.urgency == "HIGH" }.count
    }
    
    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Sayfa Başlığı ve Kısa Bilgi
                HStack {
                    Text("Bekleyen Talepler")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(filteredRequests.count) Talep")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // İstatistik Kartları
                HStack(spacing: 12) {
                    SummaryMetricCard(title: "Toplam", value: requests.count, valueColor: .black)
                    SummaryMetricCard(title: "Bekleyen", value: pendingCount, valueColor: .orange)
                    SummaryMetricCard(title: "Kritik", value: highUrgencyCount, valueColor: .red)
                }
                .padding(.horizontal)
                
                // Status Filtre Butonları
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(RequestFilter.allCases, id: \.self) { filter in
                            RequestFilterChip(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter
                            ) {
                                withAnimation { selectedFilter = filter }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Urgency Filtre Butonları
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(urgencyOptions, id: \.self) { urgency in
                            UrgencyFilterChip(
                                title: urgency == "Tümü" ? "Tümü" : urgencyDisplayName(urgency),
                                urgency: urgency,
                                isSelected: selectedUrgency == urgency
                            ) {
                                withAnimation { selectedUrgency = urgency }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // İçerik
                if isLoading {
                    ProgressView("Talepler yükleniyor...")
                        .frame(maxWidth: .infinity)
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
                            Task { await fetchRequests() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if filteredRequests.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Talep bulunamadı")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Talep Kartları Döngüsü
                    ForEach(filteredRequests, id: \.id) { request in
                        PendingRequestCardView(request: request)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom)
        }
        .background(Color(.systemGray6))
        .refreshable {
            await fetchRequests()
        }
        .task {
            await fetchRequests()
        }
    }
    
    // MARK: - Methods
    
    private func fetchRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            requests = try await requestService.fetchRequests()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [PendingRequestView] Veri çekme hatası: \(error)")
        }
        
        isLoading = false
    }
    
    private func urgencyDisplayName(_ urgency: String) -> String {
        switch urgency {
        case "HIGH": return "Yüksek"
        case "MEDIUM": return "Orta"
        case "LOW": return "Düşük"
        default: return urgency
        }
    }
}

// MARK: - Request Filter Chip

struct RequestFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.teal : Color.white)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Urgency Filter Chip

struct UrgencyFilterChip: View {
    let title: String
    let urgency: String
    let isSelected: Bool
    let action: () -> Void
    
    private var chipColor: Color {
        if !isSelected { return .white }
        switch urgency {
        case "HIGH": return .red
        case "MEDIUM": return .orange
        case "LOW": return .blue
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(chipColor)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Pending Request Card View (API DTO ile)

struct PendingRequestCardView: View {
    let request: RequestDto
    
    private var urgencyColor: Color {
        switch request.urgency {
        case "HIGH": return .red
        case "MEDIUM": return .orange
        case "LOW": return .blue
        default: return .gray
        }
    }
    
    private var statusColor: Color {
        switch request.status {
        case "PENDING": return .orange
        case "ASSIGNED": return .teal
        case "COMPLETED": return .green
        default: return .gray
        }
    }
    
    private var waitingTime: String {
        let interval = Date().timeIntervalSince(request.createdAt)
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d", hours, remainingMinutes)
        } else {
            return String(format: "00:%02d", remainingMinutes)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Üst Kısım - User ID, Status ve Urgency
            HStack {
                Text(request.userId)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(request.status)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(request.urgency)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(urgencyColor.opacity(0.2))
                    .foregroundColor(urgencyColor)
                    .clipShape(Capsule())
            }
            
            // Kullanıcı Bilgisi
            Text(request.user.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Servis ve Lokasyon
            HStack(spacing: 10) {
                IconLabel(iconName: "network", text: request.service)
                IconLabel(iconName: "mappin.and.ellipse", text: request.user.city)
            }
            
            // Request Type
            Text(request.requestType.replacingOccurrences(of: "_", with: " "))
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .foregroundColor(.purple)
                .cornerRadius(6)
            
            // Metrikler
            HStack(spacing: 15) {
                MetricBox(title: "Öncelik Skoru", value: "\(request.priorityScore)/100", showProgress: true, progressValue: Double(request.priorityScore), iconName: nil)
                MetricBox(title: "Bekleme Süresi", value: waitingTime, showProgress: false, progressValue: 0, iconName: "clock.fill")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    PendingRequestView()
}
