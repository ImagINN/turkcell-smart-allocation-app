//
//  CardViews.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct RequestCardView: View {
    let request: RequestMock
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(request.userId)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                Text(request.urgency.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(request.urgency.color.opacity(0.2))
                    .foregroundColor(request.urgency.color)
                    .clipShape(Capsule())
            }
            HStack(spacing: 10) {
                IconLabel(iconName: "network", text: request.service)
                IconLabel(iconName: "mappin.and.ellipse", text: request.location)
            }
            HStack(spacing: 15) {
                MetricBox(title: "Öncelik Skoru", value: "\(request.priorityScore)/100", showProgress: true, progressValue: Double(request.priorityScore), iconName: nil)
                MetricBox(title: "Bekleme Süresi", value: request.waitingTime, showProgress: false, progressValue: 0, iconName: "clock.fill")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ResourceCardView: View {
    let resource: ResourceMock
    
    var body: some View {
        HStack(alignment: .center) {
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
            VStack(alignment: .trailing, spacing: 4) {
                Text("STATUS")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Text(resource.status.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(resource.status.color.opacity(0.15))
                    .foregroundColor(resource.status.color)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

struct AllocationCardView: View {
    let allocation: AllocationMock
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(allocation.request.id)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text(allocation.request.userName)
                        .font(.headline)
                }
                Spacer()
                Text("İŞLEMDE")
                    .font(.caption2)
                    .fontWeight(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.teal.opacity(0.1))
                    .foregroundColor(.teal)
                    .cornerRadius(4)
            }
            Divider()
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill").foregroundColor(.secondary).frame(width: 30)
                VStack(alignment: .leading) {
                    Text("ATANAN EKİP").font(.caption2).foregroundColor(.secondary)
                    Text(allocation.resource.id).font(.subheadline).fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("LOKASYON").font(.caption2).foregroundColor(.secondary)
                    Text(allocation.resource.city).font(.subheadline)
                }
            }
            HStack {
                Label("\(allocation.timestamp) Atandı", systemImage: "clock").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("Skor: \(allocation.request.priorityScore)").font(.caption).fontWeight(.bold).foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
