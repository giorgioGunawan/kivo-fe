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
    @State private var selectedJob: GenerationJob?
    @State private var showingSignIn: Bool = false
    @State private var showingSettings: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Your Creations
                    if !appState.generationJobs.isEmpty {
                        creationsSection
                    }
                    
                    // Templates
                    templatesSection
                    
                    Spacer()
                        .frame(height: 120)
                }
            }
            .background(AppTheme.Colors.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    .buttonStyle(.plain)
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
            .navigationDestination(item: $selectedJob) { job in
                GeneratedImageDetailView(job: job)
                    .environmentObject(appState)
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
    
    @ViewBuilder
    private var unifiedCreditPill: some View {
        if appState.creditBalance.total > 0 {
            // State A: User has credits
            HStack(spacing: 5) {
                Text("🪙")
                    .font(.system(size: 12))
                
                Text("\(appState.creditBalance.total)")
                    .font(.system(size: 13, weight: .black))
            }
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .onTapGesture {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                appState.showingCreditsSheet = true
            }
        } else {
            // State B: User has ZERO credits
            Text("GET PRO")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppTheme.Colors.accent)
                )
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    appState.showingPaywall = true
                }
        }
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
    
    // MARK: - Creations Section
    
    private var creationsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Creations")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(appState.generationJobs.prefix(10)) { job in
                        CreationStatusCard(job: job)
                            .onTapGesture {
                                if case .completed = job.status {
                                    selectedJob = job
                                } else if job.status.isInProgress {
                                    appState.activeJobId = job.id
                                }
                            }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.md)
            }
        }
    }
}

// MARK: - Components

struct CreationStatusCard: View {
    let job: GenerationJob
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if case .completed(let path) = job.status {
                   let url = FileUtils.getURL(for: path)
                   if let data = try? Data(contentsOf: url),
                      let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color(uiColor: .systemGray6)
                    }
                } else if let inputURL = job.inputImageURL,
                          let data = try? Data(contentsOf: inputURL),
                          let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: job.status.isInProgress ? 10 : 0)
                        .overlay(
                            ZStack {
                                if job.status.isInProgress {
                                    Color.black.opacity(0.3)
                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                        )
                } else {
                    Color(uiColor: .systemGray6)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(.gray)
                        )
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shimmering(active: job.status.isInProgress)
            
            Text(job.templateTitle)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
            
            Text(statusText)
                .font(.system(size: 11))
                .foregroundStyle(statusColor)
        }
        .frame(width: 140)
    }
    
    private var statusText: String {
        switch job.status {
        case .queued: return "Queued..."
        case .running: return "Generating..."
        case .completed: return "Ready"
        case .failed: return "Failed"
        case .idle: return "Idle"
        }
    }
    
    private var statusColor: Color {
        switch job.status {
        case .queued, .running: return .orange
        case .completed: return .green
        case .failed: return .red
        default: return .gray
        }
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let active: Bool
    
    func body(content: Content) -> some View {
        if !active { return AnyView(content) }
        
        return AnyView(
            content
                .overlay(
                    GeometryReader { geo in
                        Color.white.opacity(0.3)
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: .init(stops: [
                                                .init(color: .clear, location: 0),
                                                .init(color: .white.opacity(0.5), location: 0.5),
                                                .init(color: .clear, location: 1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .rotationEffect(.degrees(30))
                                    .offset(x: -geo.size.width + (phase * geo.size.width * 2))
                            )
                    }
                )
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        )
    }
}

extension View {
    func shimmering(active: Bool) -> some View {
        modifier(ShimmerEffect(active: active))
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
