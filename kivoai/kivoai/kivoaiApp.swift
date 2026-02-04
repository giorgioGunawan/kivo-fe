//
//  kivoaiApp.swift
//  kivoai
//

import SwiftUI

@main
struct kivoaiApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appEnvironment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appEnvironment)
                .preferredColorScheme(.light)
        }
    }
}
