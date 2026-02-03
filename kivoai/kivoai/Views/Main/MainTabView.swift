//
//  MainTabView.swift
//  kivoai
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case album
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                if selectedTab == .home {
                    HomeView()
                } else {
                    AlbumView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom tab bar with floating button
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.kivoBackground)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Tab bar background
            HStack {
                Spacer()
                
                // Home tab
                TabBarButton(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: selectedTab == .home
                ) {
                    selectedTab = .home
                }
                
                Spacer()
                
                // Spacer for floating button
                Color.clear
                    .frame(width: 80)
                
                Spacer()
                
                // Album tab
                TabBarButton(
                    icon: "photo.stack.fill",
                    title: "Album",
                    isSelected: selectedTab == .album
                ) {
                    selectedTab = .album
                }
                
                Spacer()
            }
            .frame(height: 60)
            .background(Color.kivoCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            // Floating create button
            VStack {
                FloatingCreateButton {
                    appState.showingCustomCreation = true
                }
                .offset(y: -30)
            }
        }
        .sheet(isPresented: $appState.showingCustomCreation) {
            CustomCreationSheet()
                .environmentObject(appState)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.kivoAccent : Color.kivoTextTertiary)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? Color.kivoAccent : Color.kivoTextTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
