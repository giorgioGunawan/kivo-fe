//
//  kivoaiApp.swift
//  kivoai
//

import SwiftUI

@main
struct kivoaiApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appEnvironment = AppEnvironment()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appEnvironment)
                .environmentObject(appEnvironment.authManager)
                .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && appEnvironment.authManager.isAuthenticated {
                Task {
                    await appState.refreshCreditBalance(apiClient: appEnvironment.apiClient)
                }
            }
        }
    }
}
