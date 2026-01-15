//
//  ActiveRequestView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct ActiveAllocationsView: View {
    // Mock Veri
    let activeAllocations: [AllocationMock] = [
        AllocationMock(
            id: "AL-501",
            request: RequestMock(id: "REQ-2041", userId: "U8", userName: "Ahmet Y.", service: "Superonline", location: "Ankara", urgency: .high, priorityScore: 92, waitingTime: "12:45", addTime: Date(), status: .assigned),
            resource: ResourceMock(id: "RES-11", type: "TECH_TEAM", capacity: 3, city: "Ankara", status: .busy),
            timestamp: "14:30"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Aktif Atamalar")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(activeAllocations) { allocation in
                        AllocationCardView(allocation: allocation)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    ActiveAllocationsView()
}
