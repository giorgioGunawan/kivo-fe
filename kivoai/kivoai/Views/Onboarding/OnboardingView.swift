//
//  OnboardingView.swift
//  kivoai
//

import SwiftUI
import StoreKit
import AVFoundation

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment

    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedOptionIds: Set<String> = []
    @State private var categoryOrder: [TemplateCategory] = []
    @State private var rating: Int = 0
    @State private var showingPaywall = false
    @State private var showingDiscountOffer = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentStep) {
                    WelcomePage()
                        .tag(OnboardingStep.welcome)

                    InterestsPage(selectedOptionIds: $selectedOptionIds, categoryOrder: $categoryOrder)
                        .tag(OnboardingStep.interests)

                    HowItWorksPage()
                        .tag(OnboardingStep.howItWorks)

                    RatingPage(rating: $rating)
                        .tag(OnboardingStep.rating)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Step indicators
                HStack(spacing: 6) {
                    ForEach(OnboardingStep.allCases) { step in
                        Capsule()
                            .fill(step == currentStep
                                  ? AppTheme.Colors.textPrimary
                                  : AppTheme.Colors.separator)
                            .frame(width: step == currentStep ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStep)
                    }
                }
                .padding(.bottom, 20)

                // CTA
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    handleNext()
                } label: {
                    Text(currentStep.buttonLabel)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(LinearGradient.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, 48)
            }
        }
        .sheet(isPresented: $showingPaywall, onDismiss: handleFirstPaywallDismiss) {
            PaywallView()
                .environmentObject(appState)
                .environmentObject(appEnvironment)
        }
        .sheet(isPresented: $showingDiscountOffer, onDismiss: completeOnboarding) {
            PaywallView(isOneTimeOffer: true)
                .environmentObject(appState)
                .environmentObject(appEnvironment)
        }
    }

    // MARK: - Actions

    private func handleNext() {
        if currentStep == .interests {
            applyInterestOrder()
        }

        if currentStep.isLast {
            if rating >= 4 {
                requestReview()
            }
            showingPaywall = true
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                let all = OnboardingStep.allCases
                if let idx = all.firstIndex(of: currentStep), idx + 1 < all.count {
                    currentStep = all[idx + 1]
                }
            }
        }
    }

    private func applyInterestOrder() {
        guard !categoryOrder.isEmpty else { return }
        let rest = TemplateCategory.allCases.filter { !categoryOrder.contains($0) }
        appState.preferredCategories = categoryOrder + rest
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                #if compiler(>=6.0)
                #warning("Using deprecated API for iOS < 18")
                #endif
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }

    private func handleFirstPaywallDismiss() {
        if appState.isProSubscriber {
            completeOnboarding()
        } else {
            // Slight delay to allow previous sheet to fully dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingDiscountOffer = true
            }
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appState.completeOnboarding()
        }
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 0) {
            LoopingVideoPlayer(fileName: "KivoOnboarding", fileExtension: "mp4")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .padding(.top, 56)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Looping Video Player

private struct LoopingVideoPlayer: UIViewRepresentable {
    let fileName: String
    let fileExtension: String

    func makeUIView(context: Context) -> LoopingPlayerUIView {
        LoopingPlayerUIView(fileName: fileName, fileExtension: fileExtension)
    }

    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {}
}

private class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?

    init(fileName: String, fileExtension: String) {
        super.init(frame: .zero)

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else { return }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: item)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)

        queuePlayer.isMuted = true
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        queuePlayer.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - Interest Option

private struct InterestOption: Identifiable {
    let id: String
    let title: String
    let category: TemplateCategory

    static let allOptions: [InterestOption] = [
        InterestOption(id: "pranks", title: "Pranks", category: .pranks),
        InterestOption(id: "hair", title: "Hair", category: .appearance),
        InterestOption(id: "tattoos", title: "Tattoos", category: .appearance),
        InterestOption(id: "cartoon_me", title: "Cartoon Me", category: .cartoon),
        InterestOption(id: "young_me", title: "Young Me", category: .faceTransformations),
        InterestOption(id: "old_me", title: "Old Me", category: .faceTransformations),
        InterestOption(id: "partners", title: "Partners", category: .people),
        InterestOption(id: "celebs", title: "Celebs", category: .people),
    ]
}

// MARK: - Page 2: Interests

private struct InterestsPage: View {
    @Binding var selectedOptionIds: Set<String>
    @Binding var categoryOrder: [TemplateCategory]

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What do you want to create?")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                .padding(.top, 32)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(InterestOption.allOptions) { option in
                        InterestCard(
                            title: option.title,
                            isSelected: selectedOptionIds.contains(option.id)
                        ) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if selectedOptionIds.contains(option.id) {
                                    selectedOptionIds.remove(option.id)
                                    // Remove category from order if no options for it remain selected
                                    let categoryStillSelected = InterestOption.allOptions.contains {
                                        $0.category == option.category && selectedOptionIds.contains($0.id)
                                    }
                                    if !categoryStillSelected {
                                        categoryOrder.removeAll { $0 == option.category }
                                    }
                                } else {
                                    selectedOptionIds.insert(option.id)
                                    // Add category to order only if it's not already there
                                    if !categoryOrder.contains(option.category) {
                                        categoryOrder.append(option.category)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

private struct InterestCard: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected
                          ? AppTheme.Colors.accent.opacity(0.06)
                          : AppTheme.Colors.secondaryBackground)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? AppTheme.Colors.accent : AppTheme.Colors.separator,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Page 3: How It Works

private struct HowItWorksPage: View {
    @State private var animationPhase: Int = 0
    @State private var isActive: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Text("How it works")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            VStack(spacing: 12) {
                // Before image
                if let beforeImg = UIImage(named: "before_malecartoon") {
                    Image(uiImage: beforeImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 190, height: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }

                // Prompt pill
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent)

                    Text("\"Turn me into an action figure\"")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(AppTheme.Colors.secondaryBackground)
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.Colors.accent.opacity(0.2), lineWidth: 1)
                        )
                )
                .opacity(animationPhase >= 1 ? 1 : 0)
                .offset(y: animationPhase >= 1 ? 0 : 10)

                // After image
                if let afterImg = UIImage(named: "after_actionfigure") {
                    Image(uiImage: afterImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 190, height: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .opacity(animationPhase >= 2 ? 1 : 0)
                        .scaleEffect(animationPhase >= 2 ? 1 : 0.95)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .onAppear {
            isActive = true
            startLoop()
        }
        .onDisappear {
            isActive = false
        }
    }

    private func startLoop() {
        animationPhase = 0
        scheduleNext()
    }

    private func scheduleNext() {
        guard isActive else { return }  // Stop if view is no longer active
        
        // TIMING CONFIGURATION (adjust these values as needed)
        let phase1Duration: Double = 1.5  // Before image visible
        let phase2Duration: Double = 1.5  // Prompt pill visible
        let phase3Duration: Double = 5.0  // After image visible (includes hold before loop)
        
        let currentDuration: Double
        switch animationPhase {
        case 0: currentDuration = phase1Duration
        case 1: currentDuration = phase2Duration
        case 2: currentDuration = phase3Duration
        default: currentDuration = 1.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentDuration) {
            guard isActive else { return }  // Double-check before animating
            
            withAnimation(.easeInOut(duration: 0.5)) {
                animationPhase = (animationPhase + 1) % 3  // Loop back to 0 after 2
            }
            scheduleNext()
        }
    }
}

// MARK: - Page 4: Rating

private struct RatingPage: View {
    @Binding var rating: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text("Loving Kivo?")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Your rating helps us grow!")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Stars
                HStack(spacing: 14) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                rating = star
                            }
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    star <= rating
                                    ? Color(red: 1.0, green: 0.76, blue: 0.0)
                                    : AppTheme.Colors.textQuaternary
                                )
                                .scaleEffect(star <= rating ? 1.15 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if rating > 0 {
                    Text(ratingMessage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: rating)
    }

    private var ratingMessage: String {
        switch rating {
        case 1: return "We'll do better. Promise."
        case 2: return "Thanks — we're listening."
        case 3: return "Solid. We'll keep improving."
        case 4: return "Love that! Thank you."
        case 5: return "You're amazing. Thank you!"
        default: return ""
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
