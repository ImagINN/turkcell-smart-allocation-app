//
//  DashboardView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct DashboardView: View {
    @Binding var selectedTab: Int
    
    let pendingRequests: [RequestMock] = [
        RequestMock(id: "REQ-2041", userId: "U8", userName: "Ahmet Yılmaz", service: "Superonline", location: "Ankara", urgency: .high, priorityScore: 92, waitingTime: "14:25", addTime: Date(), status: .pending),
        RequestMock(id: "REQ-1050", userId: "U12", userName: "Ayşe Demir", service: "Mobil", location: "İstanbul", urgency: .medium, priorityScore: 65, waitingTime: "08:12", addTime: Date(), status: .pending)
    ]
    
    let activeAllocations: [AllocationMock] = [
        AllocationMock(id: "AL-501", request: RequestMock(id: "REQ-2041", userId: "U8", userName: "Ahmet Y.", service: "Superonline", location: "Ankara", urgency: .high, priorityScore: 92, waitingTime: "12:45", addTime: Date(), status: .assigned), resource: ResourceMock(id: "RES-11", type: "TECH_TEAM", capacity: 3, city: "Ankara", status: .busy), timestamp: "14:30")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Turkcell Smart Allocation")
                        .font(.title)
                        .fontWeight(.black)
                    Spacer()
                    Image(systemName: "bell.badge")
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    SummaryMetricCard(title: "Bekleyen Talep", value: 5, valueColor: .blue)
                        .onTapGesture { selectedTab = 1 }
                    SummaryMetricCard(title: "Uygun Ekip", value: 12, valueColor: .black)
                        .onTapGesture { selectedTab = 2 }
                    SummaryMetricCard(title: "Aktif İşlem", value: 8, valueColor: .green)
                        .onTapGesture { selectedTab = 3 }
                }
                .padding(.horizontal)
                
                VStack(spacing: 15) {
                    SectionHeader(title: "Kritik Talepler") { selectedTab = 1 }
                    ForEach(pendingRequests) { request in
                        RequestCardView(request: request).padding(.horizontal)
                    }
                }
                
                VStack(spacing: 15) {
                    SectionHeader(title: "Aktif İşlemler") { selectedTab = 3 }
                    ForEach(activeAllocations) { allocation in
                        AllocationCardView(allocation: allocation).padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
    }
}
