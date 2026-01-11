//
//  OvertimeTrackerApp.swift
//  OvertimeTracker
//
//  Created on 2026-01-11
//

import SwiftUI

@main
struct OvertimeTrackerApp: App {
    @StateObject private var dataManager = OvertimeDataManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
