//
//  ContentView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var requests: [RequestDto] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let requestService = RequestService()
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Veriler yükleniyor...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Hata: \(error)")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                        Button("Tekrar Dene") {
                            Task {
                                await fetchRequests()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if requests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Henüz veri yok")
                            .foregroundColor(.gray)
                    }
                } else {
                    List(requests, id: \.id) { request in
                        RequestRowView(request: request)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Talepler")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await fetchRequests()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
        }
        .task {
            await fetchRequests()
        }
    }
    
    private func fetchRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            requests = try await requestService.fetchRequests()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Veri çekme hatası: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Request Row View

struct RequestRowView: View {
    let request: RequestDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(request.user.name)
                    .font(.headline)
                Spacer()
                StatusBadge(status: request.status)
            }
            
            HStack {
                Label(request.service, systemImage: "gear")
                Spacer()
                Label(request.requestType, systemImage: "tag")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                UrgencyBadge(urgency: request.urgency)
                Spacer()
                Text("Skor: \(request.priorityScore)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if let allocation = request.allocation {
                HStack {
                    Image(systemName: "location")
                    Text(allocation.resource.city)
                    Spacer()
                    Text(allocation.resource.resourceType)
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status.uppercased() {
        case "COMPLETED":
            return .green
        case "ASSIGNED":
            return .blue
        case "PENDING":
            return .orange
        default:
            return .gray
        }
    }
}

// MARK: - Urgency Badge

struct UrgencyBadge: View {
    let urgency: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: urgencyIcon)
            Text(urgency)
        }
        .font(.caption.weight(.medium))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(urgencyColor.opacity(0.2))
        .foregroundColor(urgencyColor)
        .cornerRadius(8)
    }
    
    private var urgencyColor: Color {
        switch urgency.uppercased() {
        case "HIGH":
            return .red
        case "MEDIUM":
            return .orange
        case "LOW":
            return .green
        default:
            return .gray
        }
    }
    
    private var urgencyIcon: String {
        switch urgency.uppercased() {
        case "HIGH":
            return "exclamationmark.2"
        case "MEDIUM":
            return "exclamationmark"
        case "LOW":
            return "checkmark"
        default:
            return "questionmark"
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
