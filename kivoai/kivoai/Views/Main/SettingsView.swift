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
                #if DEBUG
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
                #endif

                Section("Support") {
                    CopyableRow(label: "Contact Us", value: "onesmllab@gmail.com")
                }

                Section("Account") {
                    if appEnvironment.authManager.isAuthenticated {
                        if let userId = appEnvironment.authManager.getUserIdentifier() {
                            CopyableRow(label: "User ID", value: userId)
                        }

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

private struct CopyableRow: View {
    let label: String
    let value: String
    @State private var copied = false

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .font(.system(.caption, design: .monospaced))
            Button {
                UIPasteboard.general.string = value
                withAnimation { copied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { copied = false }
                }
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 13))
                    .foregroundStyle(copied ? .green : AppTheme.Colors.textTertiary)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
