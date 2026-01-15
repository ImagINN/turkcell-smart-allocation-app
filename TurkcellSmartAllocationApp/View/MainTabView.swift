//
//  MainTabView.swift
//  TurkcellSmartAllocationApp
//
//  Created by Missy on 15.01.2026.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }
                .tag(0)
            
            PendingRequestView()
                .tabItem { Label("Talepler", systemImage: "list.bullet.rectangle.fill") }
                .tag(1)
            
            ResourcesView()
                .tabItem { Label("Kaynaklar", systemImage: "person.3.fill") }
                .tag(2)
            
            ActiveAllocationsView()
                .tabItem { Label("Atamalar", systemImage: "arrow.up.arrow.down.circle.fill") }
                .tag(3)
        }
        .accentColor(.teal)
    }
}
