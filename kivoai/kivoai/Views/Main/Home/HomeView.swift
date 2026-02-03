//
//  HomeView.swift
//  kivoai
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.kivoBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header section
                        headerSection
                        
                        // Templates section
                        templatesSection
                        
                        // Bottom padding for tab bar
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Kivo")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.kivoTextPrimary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    proButton
                }
            }
            .sheet(isPresented: $appState.showingPaywall) {
                PaywallView()
                    .environmentObject(appState)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome back ✨")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.kivoTextPrimary)
            
            HStack {
                CreditBalanceView(balance: appState.creditBalance)
                
                Spacer()
                
                Button {
                    appState.showingCustomCreation = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Create")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.kivoAccent)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Templates Section
    
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Templates")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.kivoTextPrimary)
                .padding(.horizontal, 20)
            
            ForEach(TemplateCategory.allCases) { category in
                CategorySection(category: category)
            }
        }
    }
    
    // MARK: - Pro Button
    
    private var proButton: some View {
        Button {
            appState.showingPaywall = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: appState.isProSubscriber ? "star.fill" : "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                Text(appState.isProSubscriber ? "Pro" : "Get Pro")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(appState.isProSubscriber ? .white : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Group {
                    if appState.isProSubscriber {
                        Color.kivoAccent
                    } else {
                        LinearGradient(
                            colors: [Color.kivoAccent, Color.kivoPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct CategorySection: View {
    let category: TemplateCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.kivoAccent)
                
                Text(category.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.kivoTextPrimary)
            }
            .padding(.horizontal, 20)
            
            // Template horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Template.templates(for: category)) { template in
                        NavigationLink(destination: TemplateDetailView(template: template)) {
                            TemplateCardView(template: template)
                                .frame(width: 160) // Fixed width for horizontal layout
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
