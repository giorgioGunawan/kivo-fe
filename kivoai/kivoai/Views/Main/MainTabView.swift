//
//  MainTabView.swift
//  kivoai
//
//  Tab bar following the pattern: tabs on left, floating create on right.
//  Refined to look native with labels and material effects.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment

    @State private var showingSignIn: Bool = false
    @State private var toastJob: GenerationJob? = nil



    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            HomeView()
                .opacity(appState.selectedTab == .home ? 1 : 0)
                .id(AppTab.home)

            AlbumView()
                .opacity(appState.selectedTab == .library ? 1 : 0)
                .id(AppTab.library)

            // Tab Bar Area
            tabBar
                .offset(y: appState.tabBarHidden ? 120 : 0)
                .opacity(appState.tabBarHidden ? 0 : 1)
        }
        .ignoresSafeArea(.keyboard)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appState.tabBarHidden)
        // Completion toast
        .overlay(alignment: .top) {
            if let _ = toastJob {
                CompletionToastView {
                    withAnimation(.spring(response: 0.3)) {
                        toastJob = nil
                    }
                    appState.selectedTab = .library
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastJob?.id)
        .onChange(of: appState.completionNotification?.id) { _, newId in
            guard newId != nil else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                toastJob = appState.completionNotification
            }
            appState.completionNotification = nil
            // Auto-dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.spring(response: 0.3)) {
                    toastJob = nil
                }
            }
        }
        .sheet(isPresented: $showingSignIn) {
            SignInView {
                showingSignIn = false
                Task {
                    await appState.refreshCreditBalance(apiClient: appEnvironment.apiClient)
                    appState.showingCustomCreation = true
                }
            }
            .environmentObject(appEnvironment.authManager)
        }
        .sheet(isPresented: $appState.showingCustomCreation) {
            CustomCreationSheet()
                .environmentObject(appState)
        }
        .onAppear {
            if appEnvironment.authManager.isAuthenticated {
                Task {
                    await appState.refreshCreditBalance(apiClient: appEnvironment.apiClient)
                }
            }
        }
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // Left Side: Tabs in a shadowed pill
            HStack(spacing: 0) {
                TabButton(
                    icon: "house.fill",
                    label: "Home",
                    isSelected: appState.selectedTab == .home
                ) {
                    appState.selectedTab = .home
                }
                
                TabButton(
                    icon: "photo.on.rectangle.angled.fill",
                    label: "Library",
                    isSelected: appState.selectedTab == .library
                ) {
                    appState.selectedTab = .library
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 8)
            )
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
            )
            
            Spacer()
            
            // Right Side: Floating Create
            createButton
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, 34) // Above home indicator
    }
    private var createButton: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            if appEnvironment.authManager.isAuthenticated {
                appState.showingCustomCreation = true
            } else {
                showingSignIn = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(LinearGradient.accentGradient)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),
                                        .white.opacity(0.1),
                                        .white.opacity(0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 10, x: 0, y: 5)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            let haptic = UIImpactFeedbackGenerator(style: .medium)
            haptic.impactOccurred()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .bold : .medium))
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundStyle(isSelected ? .black : Color.black.opacity(0.4))
            .frame(width: 70, height: 48)
            .contentShape(Rectangle())
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Completion Toast

private struct CompletionToastView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                Text("Creation ready")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.textPrimary)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
