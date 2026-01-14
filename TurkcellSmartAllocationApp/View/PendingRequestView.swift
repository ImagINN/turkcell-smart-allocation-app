//
//  RequestView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct PendingRequestView: View {
    // Mock Data Seti - Normalde bu ViewModel'den gelecek
    // Skorlara göre büyükten küçüğe sıralıyoruz
    let requests: [RequestMock] = [
        RequestMock(id: "REQ-2041", userId: "U8", service: "Superonline", location: "Ankara", urgency: .high, priorityScore: 92, waitingTime: "14:25"),
        RequestMock(id: "REQ-1050", userId: "U12", service: "Mobil", location: "İstanbul", urgency: .medium, priorityScore: 65, waitingTime: "08:12"),
        RequestMock(id: "REQ-0012", userId: "U3", service: "TV+", location: "İzmir", urgency: .low, priorityScore: 30, waitingTime: "02:45")
    ].sorted(by: { $0.priorityScore > $1.priorityScore }) // [cite: 57, 83]

    var body: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Sayfa Başlığı ve Kısa Bilgi
                    HStack {
                        Text("Bekleyen Talepler")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(requests.count) Talep")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Talep Kartları Döngüsü
                    ForEach(requests) { request in
                        RequestCardView(request: request)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .background(Color(.systemGray6)) // Kartların öne çıkması için hafif gri arka plan
        }
}

#Preview {
    PendingRequestView()
}
