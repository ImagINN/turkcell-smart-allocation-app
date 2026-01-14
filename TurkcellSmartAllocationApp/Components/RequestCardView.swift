//
//  RequestCardView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 14.01.2026.
//

import SwiftUI

struct RequestCardView: View {
    let request: RequestMock
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Üst Kısım: ID'ler ve Urgency Label
            HStack {
                HStack {
                    Text(request.id) // [cite: 17]
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        //.background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                // Urgency Badge [cite: 21]
                Text(request.urgency.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(request.urgency.color.opacity(0.2))
                    .foregroundColor(request.urgency.color)
                    .clipShape(Capsule())
            }
            
            // Orta Bölüm: Etiketler [cite: 13, 19, 35, 50]
            HStack(spacing: 10) {
                IconLabel(iconName: "network", text: request.service)
                IconLabel(iconName: "mappin.and.ellipse", text: request.location)
            }
            
            // Alt Bölüm: Metrik Kutuları [cite: 38, 45, 75]
            HStack(spacing: 15) {
                MetricBox(
                    title: "Öncelik Skoru",
                    value: "\(request.priorityScore)/100",
                    showProgress: true,
                    progressValue: Double(request.priorityScore),
                    iconName: nil
                )
                
                MetricBox(
                    title: "Bekleme Süresi", // [cite: 44]
                    value: request.waitingTime,
                    showProgress: false,
                    progressValue: 0,
                    iconName: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ZStack {
        Color(.systemGray5).ignoresSafeArea() // Arka planı belli etmesi için gri zemin
        
        VStack(spacing: 20) {
            // Senaryo 1: Yüksek Öncelikli (High Urgency)
            RequestCardView(request: RequestMock(
                id: "REQ-2041",
                userId: "U8",
                service: "Superonline",
                location: "Ankara",
                urgency: .high,
                priorityScore: 92,
                waitingTime: "14:25"
            ))
            
            // Senaryo 2: Orta Öncelikli (Medium Urgency)
            RequestCardView(request: RequestMock(
                id: "REQ-1050",
                userId: "U12",
                service: "Mobil",
                location: "İstanbul",
                urgency: .medium,
                priorityScore: 65,
                waitingTime: "08:12"
            ))
            
            // Senaryo 3: Düşük Öncelikli (Low Urgency)
            RequestCardView(request: RequestMock(
                id: "REQ-0012",
                userId: "U3",
                service: "TV+",
                location: "İzmir",
                urgency: .low,
                priorityScore: 30,
                waitingTime: "02:45"
            ))
        }
        .padding()
    }
}
