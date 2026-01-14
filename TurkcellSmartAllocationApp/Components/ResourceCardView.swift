//
//  ResourceCardView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct ResourceCardView: View {
    let resource: ResourceMock
    
    var body: some View {
        HStack(alignment: .center) {
            // SOL: Kapasite
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
            
            // ORTA: Şehir
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
            
            // SAĞ: Müsaitlik Durumu (Badge/Capsule)
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
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
