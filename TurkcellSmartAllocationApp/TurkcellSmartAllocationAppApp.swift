//
//  TurkcellSmartAllocationAppApp.swift
//  TurkcellSmartAllocationApp
//
//  Created by Gokhan on 14.01.2026.
//

import SwiftUI

@main
struct TurkcellSmartAllocationAppApp: App {
    var body: some Scene {
        WindowGroup {
            ResourcesView(totalTeams: 1, activeTeams: 1, idleTeams: 1)
        }
    }
}
