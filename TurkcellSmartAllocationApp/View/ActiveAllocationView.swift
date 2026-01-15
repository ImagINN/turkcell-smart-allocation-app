//
//  ActiveRequestView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct ActiveAllocationsView: View {
    
    // MARK: - State Properties
    
    @State private var allocations: [AllocationFullDto] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFilter: AllocationFilter = .all
    
    // MARK: - Services
    
    private let allocationService = AllocationService()
    
    // MARK: - Filter Enum
    
    enum AllocationFilter: String, CaseIterable {
        case all = "Tümü"
        case assigned = "Atandı"
        case completed = "Tamamlandı"
    }
    
    // MARK: - Computed Properties
    
    private var filteredAllocations: [AllocationFullDto] {
        switch selectedFilter {
        case .all:
            return allocations
        case .assigned:
            return allocations.filter { $0.status == .assigned }
        case .completed:
            return allocations.filter { $0.status == .completed }
        }
    }
    
    private var assignedCount: Int {
        allocations.filter { $0.status == .assigned }.count
    }
    
    private var completedCount: Int {
        allocations.filter { $0.status == .completed }.count
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Aktif Atamalar")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // İstatistik Kartları
                    HStack(spacing: 12) {
                        SummaryMetricCard(title: "Toplam", value: allocations.count, valueColor: .black)
                        SummaryMetricCard(title: "Atandı", value: assignedCount, valueColor: .orange)
                        SummaryMetricCard(title: "Tamamlandı", value: completedCount, valueColor: .green)
                    }
                    .padding(.horizontal)
                    
                    // Filtre Butonları
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AllocationFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    count: countFor(filter: filter)
                                ) {
                                    withAnimation { selectedFilter = filter }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // İçerik
                    if isLoading {
                        ProgressView("Atamalar yükleniyor...")
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
                                Task { await fetchAllocations() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else if filteredAllocations.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Atama bulunamadı")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(filteredAllocations, id: \.id) { allocation in
                            ActiveAllocationCardView(allocation: allocation)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
        .refreshable {
            await fetchAllocations()
        }
        .task {
            await fetchAllocations()
        }
    }
    
    // MARK: - Methods
    
    private func fetchAllocations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            allocations = try await allocationService.fetchAllocations()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [ActiveAllocationsView] Veri çekme hatası: \(error)")
        }
        
        isLoading = false
    }
    
    private func countFor(filter: AllocationFilter) -> Int {
        switch filter {
        case .all: return allocations.count
        case .assigned: return assignedCount
        case .completed: return completedCount
        }
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
                
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
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

// MARK: - Active Allocation Card View (API DTO ile)

struct ActiveAllocationCardView: View {
    let allocation: AllocationFullDto
    
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return formatter.string(from: allocation.timestamp)
    }
    
    private var statusColor: Color {
        allocation.status == .assigned ? .teal : .green
    }
    
    private var statusText: String {
        allocation.status == .assigned ? "İŞLEMDE" : "TAMAMLANDI"
    }
    
    private var urgencyColor: Color {
        switch allocation.request.urgency {
        case "HIGH": return .red
        case "MEDIUM": return .orange
        case "LOW": return .blue
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Üst Kısım - Request ID, Kullanıcı ve Status
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(allocation.request.id)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text(allocation.request.user.name)
                        .font(.headline)
                }
                Spacer()
                Text(statusText)
                    .font(.caption2)
                    .fontWeight(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }
            
            Divider()
            
            // Orta Kısım - Ekip ve Lokasyon
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 30)
                VStack(alignment: .leading) {
                    Text("ATANAN EKİP")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(allocation.resource.id)
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
            
            // Servis ve Urgency Bilgisi
            HStack(spacing: 8) {
                Text(allocation.request.service)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                
                Text(allocation.request.requestType.replacingOccurrences(of: "_", with: " "))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.gray)
                    .cornerRadius(6)
                
                Text(allocation.request.urgency)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(urgencyColor.opacity(0.1))
                    .foregroundColor(urgencyColor)
                    .cornerRadius(6)
            }
            
            // Alt Kısım - Zaman ve Skor
            HStack {
                Label("\(formattedTimestamp) Atandı", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
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

#Preview {
    ActiveAllocationsView()
}
