//
//  SettingsView.swift
//  kivoai
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Debug") {
                    Toggle("Simulate Zero Credits", isOn: $appState.debugZeroCredits)
                    
                    Button(role: .destructive) {
                        dismiss()
                        // Small delay to ensure sheet dismisses before state change triggers view swap
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            appState.resetAll()
                        }
                    } label: {
                        Label("Restart Onboarding", systemImage: "arrow.counterclockwise.circle")
                    }
                }
                
                Section("Account") {
                    if appEnvironment.authManager.isAuthenticated {
                        Button(role: .destructive) {
                            dismiss()
                            appEnvironment.authManager.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } else {
                        Text("Not signed in")
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
