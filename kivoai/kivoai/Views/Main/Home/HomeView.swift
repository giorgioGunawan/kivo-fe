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
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.Colors.textTertiary)
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
                    .environmentObject(appEnvironment)
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
        let balance = appState.creditBalance
        let hasCredits = balance.total > 0 && !appState.debugZeroCredits

        if hasCredits {
            // State A: User has credits — show combined total
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                appState.showingCreditsSheet = true
            } label: {
                HStack(spacing: 4) {
                    Text("🪙")
                        .font(.system(size: 12))

                    Text(verbatim: String(balance.total))
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        } else {
            // State B: No credits at all
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appState.showingPaywall = true
            } label: {
                Text("GET PRO")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, 6)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Templates
    
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(TemplateCategory.allCases) { category in
                CategorySection(category: category, selectedTemplate: $selectedTemplate, showingSignIn: $showingSignIn)
                    .environmentObject(appEnvironment)
                    .environmentObject(appState)
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
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, 4)
            }
        }
    }
}

// MARK: - Components

struct CreationStatusCard: View {
    let job: GenerationJob
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
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

            statusPill
                .padding(.top, 8)
                .padding(.trailing, 8)
        }
        .frame(width: 140, height: 140)
    }

    private var statusPill: some View {
        Text(statusText)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.85))
            )
    }

    private var statusText: String {
        switch job.status {
        case .queued: return "Queued"
        case .running: return "Generating"
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
    @EnvironmentObject var appState: AppState

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

                    // Custom card at end of each category
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if appEnvironment.authManager.isAuthenticated {
                            appState.showingCustomCreation = true
                        } else {
                            showingSignIn = true
                        }
                    } label: {
                        CustomCardView()
                            .frame(width: 170)
                    }
                    .buttonStyle(TemplateButtonStyle())
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, 32)
            }
        }
    }
}

// MARK: - Custom Card

struct CustomCardView: View {
    var body: some View {
        ZStack {
            Color.white

            LinearGradient(
                colors: [Color(red: 0.32, green: 0.32, blue: 0.42), Color(red: 0.20, green: 0.20, blue: 0.30)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 52, height: 52)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }

                Text("Custom")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }

            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .aspectRatio(0.75, contentMode: .fill)
        .templateCardStyle()
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
