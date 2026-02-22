//
//  SettingsView.swift
//  kivoai
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deleteError: String?

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
                    CopyableRow(label: "Contact Us", value: "kivoai@protonmail.com")
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

                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                        }
                    } else {
                        Text("Not signed in")
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }

                Section("Legal") {
                    NavigationLink {
                        AcceptableUsePolicyView()
                    } label: {
                        Label("Acceptable Use Policy", systemImage: "doc.text")
                    }
                }

                Section {
                    Text("Images are processed securely. Kivo AI does not permanently store your photos.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
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
            .alert("Delete Account?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and associated data. This action cannot be undone.")
            }
            .alert("Error", isPresented: .init(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )) {
                Button("OK") { deleteError = nil }
            } message: {
                Text(deleteError ?? "")
            }
        }
    }

    private func deleteAccount() {
        isDeleting = true
        Task {
            do {
                try await appEnvironment.apiClient.deleteAccount()
                appState.resetAll()
                appEnvironment.authManager.signOut()
                dismiss()
            } catch {
                deleteError = "Failed to delete account. Please try again or contact support."
            }
            isDeleting = false
        }
    }
}

// MARK: - Acceptable Use Policy

private struct AcceptableUsePolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Acceptable Use Policy")
                    .font(.title2.bold())

                Group {
                    policyItem("No Illegal Content", description: "Do not use Kivo AI to generate content that violates any applicable laws or regulations.")

                    policyItem("No Explicit Sexual Content", description: "Creating sexually explicit or pornographic imagery is strictly prohibited.")

                    policyItem("No Harassment or Impersonation", description: "Do not use Kivo AI to harass, bully, or impersonate others.")

                    policyItem("No Non-Consensual Edits", description: "Do not create or distribute edited images of real people without their consent.")
                }

                Text("Violation of these guidelines may result in account suspension or termination.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(24)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policyItem(_ title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Copyable Row

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
