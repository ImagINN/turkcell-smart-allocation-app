//
//  ResourcesView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct ResourcesView: View {
    
    // MARK: - Properties
    
    @State private var resources: [ResourceFullDto] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedCity: String = "Tümü"
    
    private let resourceService = ResourceService()
    
    // Şehir filtreleme seçenekleri
    private var cities: [String] {
        var citySet = Set(resources.map { $0.city })
        citySet.insert("Tümü")
        return ["Tümü"] + Array(citySet.filter { $0 != "Tümü" }).sorted()
    }
    
    // Filtrelenmiş kaynaklar
    private var filteredResources: [ResourceFullDto] {
        if selectedCity == "Tümü" {
            return resources
        }
        return resources.filter { $0.city == selectedCity }
    }
    
    // İstatistikler
    private var totalTeams: Int { filteredResources.count }
    private var activeTeams: Int { filteredResources.filter { $0.status == .busy }.count }
    private var idleTeams: Int { filteredResources.filter { $0.status == .available }.count }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Kaynak Yönetimi")
                .font(.title2)
                .bold()
                .padding()
            
            // İstatistik Kartları
            HStack(spacing: 12) {
                SummaryMetricCard(title: "Teams", value: totalTeams, valueColor: .black)
                SummaryMetricCard(title: "Active", value: activeTeams, valueColor: .green)
                SummaryMetricCard(title: "Idle", value: idleTeams, valueColor: .gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            // Şehir Filtresi Tab Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {
                    ForEach(cities, id: \.self) { city in
                        VStack(spacing: 8) {
                            Text(city)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(selectedCity == city ? .teal : .secondary)
                            
                            Rectangle()
                                .fill(selectedCity == city ? .teal : Color.clear)
                                .frame(height: 3)
                                .cornerRadius(2)
                        }
                        .onTapGesture {
                            withAnimation { selectedCity = city }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .background(Color.white)
            
            Divider()
            
            // İçerik
            if isLoading {
                Spacer()
                ProgressView("Kaynaklar yükleniyor...")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Hata: \(error)")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                    Button("Tekrar Dene") {
                        Task { await fetchResources() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                Spacer()
            } else if filteredResources.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Kaynak bulunamadı")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                // Kaynak Listesi
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredResources, id: \.id) { resource in
                            ResourceCardViewNew(resource: resource)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6).opacity(0.5))
                .refreshable {
                    await fetchResources()
                }
            }
        }
        .task {
            await fetchResources()
        }
    }
    
    // MARK: - Methods
    
    private func fetchResources() async {
        isLoading = true
        errorMessage = nil
        
        do {
            resources = try await resourceService.fetchResources()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [ResourcesView] Veri çekme hatası: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Resource Card View (Network DTO ile)

struct ResourceCardViewNew: View {
    let resource: ResourceFullDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Üst Kısım - ID ve Status
            HStack {
                Text(resource.id)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(resource.status.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // Orta Kısım - Detaylar
            HStack(alignment: .center) {
                // Kapasite
                VStack(alignment: .leading, spacing: 4) {
                    Text("CAPACITY")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text("\(resource.capacity) Kişi")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Şehir
                VStack(alignment: .leading, spacing: 4) {
                    Text("CITY")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(resource.city)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Kullanım Oranı
                VStack(alignment: .trailing, spacing: 4) {
                    Text("UTILIZATION")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text("%\(resource.utilization)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(utilizationColor)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // Alt Kısım - Aktif Atamalar
            if resource.activeAllocations > 0 {
                Divider()
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.teal)
                    Text("\(resource.activeAllocations) Aktif Atama")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Atama detayları
                    ForEach(resource.allocations.prefix(2), id: \.id) { allocation in
                        Text(allocation.request.service)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.teal.opacity(0.1))
                            .foregroundColor(.teal)
                            .cornerRadius(8)
                    }
                    
                    if resource.allocations.count > 2 {
                        Text("+\(resource.allocations.count - 2)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(.systemGray5), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private var statusColor: Color {
        resource.status == .available ? .green : .orange
    }
    
    private var utilizationColor: Color {
        if resource.utilization >= 80 {
            return .red
        } else if resource.utilization >= 50 {
            return .orange
        } else {
            return .green
        }
    }
}

// MARK: - Preview

#Preview {
    ResourcesView()
}
