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
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case library
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                if selectedTab == .home {
                    HomeView()
                } else {
                    AlbumView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Tab Bar Area
            tabBar
                .offset(y: appState.tabBarHidden ? 120 : 0)
                .opacity(appState.tabBarHidden ? 0 : 1)
        }
        .ignoresSafeArea(.keyboard)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appState.tabBarHidden)
        .sheet(isPresented: $appState.showingCustomCreation) {
            CustomCreationSheet()
                .environmentObject(appState)
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
                    isSelected: selectedTab == .home
                ) {
                    selectedTab = .home
                }
                
                TabButton(
                    icon: "photo.on.rectangle.angled.fill",
                    label: "Library",
                    isSelected: selectedTab == .library
                ) {
                    selectedTab = .library
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
            appState.showingCustomCreation = true
        } label: {
            ZStack {
                Circle()
                    .fill(LinearGradient.accentGradient)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(white: 0.9), Color(white: 0.7), Color(white: 0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
            }
            .shadow(color: AppTheme.Colors.accent.opacity(0.35), radius: 12, x: 0, y: 6)
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
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .bold : .medium))
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundStyle(isSelected ? .black : Color.black.opacity(0.5))
            .frame(width: 64, height: 48)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
