//
//  HomeView.swift
//  kivoai
//
//  Native, content-first home screen with template browsing.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var selectedTemplate: Template?
    @State private var showingSignIn: Bool = false
    @State private var showingSettings: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Templates
                    templatesSection
                    
                    Spacer()
                        .frame(height: 120)
                }
            }
            .background(AppTheme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("Home")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    unifiedCreditPill
                }
            }
            .navigationDestination(item: $selectedTemplate) { template in
                TemplateDetailView(template: template)
                    .environmentObject(appState)
                    .environmentObject(appEnvironment)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(appState)
                    .environmentObject(appEnvironment)
            }
            .sheet(isPresented: $showingSignIn) {
                SignInView {
                    // Success callback
                    showingSignIn = false
                }
                .environmentObject(appEnvironment.authManager)
            }
            .sheet(isPresented: $appState.showingCreditsSheet) {
                CreditDetailsSheet()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $appState.showingPaywall) {
                PaywallView()
                    .environmentObject(appState)
            }
        }
    }
    
    // MARK: - Header Info
    
    private var unifiedCreditPill: some View {
        Group {
            if appState.creditBalance.total > 0 {
                // State A: User has credits
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    appState.showingCreditsSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("🪙")
                            .font(.system(size: 13))
                        
                        Text("\(appState.creditBalance.total)")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(Capsule())
                }
            } else {
                // State B: User has ZERO credits
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    appState.showingPaywall = true
                } label: {
                    Text("Get Pro")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(LinearGradient.accentGradient)
                        .clipShape(Capsule())
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Templates
    
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(TemplateCategory.allCases) { category in
                CategorySection(category: category, selectedTemplate: $selectedTemplate, showingSignIn: $showingSignIn)
                    .environmentObject(appEnvironment)
            }
        }
    }
}

// MARK: - Category Section

struct CategorySection: View {
    let category: TemplateCategory
    @Binding var selectedTemplate: Template?
    @Binding var showingSignIn: Bool
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(category.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppTheme.Spacing.md) {
                    ForEach(Template.templates(for: category)) { template in
                        Button {
                            if appEnvironment.authManager.isAuthenticated {
                                selectedTemplate = template
                            } else {
                                showingSignIn = true
                            }
                        } label: {
                            TemplateCardView(template: template)
                                .frame(width: 170)
                        }
                        .buttonStyle(TemplateButtonStyle())
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, 32)
            }
        }
    }
}

// MARK: - Button Style

struct TemplateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
