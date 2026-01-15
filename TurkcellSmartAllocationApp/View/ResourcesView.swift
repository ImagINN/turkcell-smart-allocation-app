//
//  ResourcesView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct ResourcesView: View {
    // Backend'den gelecek dinamik kategoriler
    let categories = ["TECH_TEAM", "SUPPORT", "LOGISTICS", "MAINTENANCE"]
    @State private var selectedCategory = "TECH_TEAM"
    
    let totalTeams: Int
    let activeTeams: Int
    let idleTeams: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Kaynak Yönetimi")
                .font(.title2)
                .bold()
                .padding()
                
            
            HStack(spacing: 12) {
                SummaryMetricCard(title: "Teams", value: totalTeams, valueColor: .black)
                SummaryMetricCard(title: "Active", value: activeTeams, valueColor: .green)
                SummaryMetricCard(title: "Idle", value: idleTeams, valueColor: .gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            
            // Dinamik Kaydırılabilir Tab Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {
                    ForEach(categories, id: \.self) { category in
                        VStack(spacing: 8) {
                            Text(category.replacingOccurrences(of: "_", with: " "))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(selectedCategory == category ? .teal : .secondary)
                            
                            // Seçili alt çizgi
                            Rectangle()
                                .fill(selectedCategory == category ? .teal : Color.clear)
                                .frame(height: 3)
                                .cornerRadius(2)
                        }
                        .onTapGesture {
                            withAnimation { selectedCategory = category }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .background(Color.white)
            
            Divider()
            
            // Kaynak Listesi
            ScrollView {
                VStack(spacing: 15) {
                    
                    // Örnek Kartlar
                    ResourceCardView(resource: ResourceMock(id: "RES-1", type: "TECH_TEAM", capacity: 5, city: "Ankara", status: .available))
                    ResourceCardView(resource: ResourceMock(id: "RES-2", type: "TECH_TEAM", capacity: 3, city: "Ankara", status: .busy))
                    ResourceCardView(resource: ResourceMock(id: "RES-3", type: "TECH_TEAM", capacity: 8, city: "Ankara", status: .available))
                }
                .padding()
            }
            .background(Color(.systemGray6).opacity(0.5))
        }
    }
}
