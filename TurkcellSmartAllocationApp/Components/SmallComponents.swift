//
//  Components.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 14.01.2026.
//

import SwiftUI

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

struct SummaryMetricCard: View {
    let title: String
    let value: Int
    let valueColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(Color(.systemGray2))
            
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct SectionHeader: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Button(action: action) {
                Text("Tümünü Gör")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}
