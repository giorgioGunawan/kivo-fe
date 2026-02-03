//
//  ContentView.swift
//  kivoai
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
