//
//  Components.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 14.01.2026.
//

import Foundation
import SwiftUI

// MARK: - Icon Label (Servis ve Lokasyon için)
struct IconLabel: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 14))
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Metric Box (Skor ve Sayaç için)
struct MetricBox: View {
    let title: String
    let value: String
    let showProgress: Bool
    let progressValue: Double
    let iconName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            HStack {
                if let icon = iconName {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                }
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if showProgress {
                ProgressView(value: progressValue, total: 100)
                    .tint(.blue)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
