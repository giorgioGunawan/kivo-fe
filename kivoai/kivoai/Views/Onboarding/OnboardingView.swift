//
//  OnboardingView.swift
//  kivoai
//

import SwiftUI
import StoreKit

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment

    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedInterests: Set<TemplateCategory> = []
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

                    InterestsPage(selectedInterests: $selectedInterests)
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
        guard !selectedInterests.isEmpty else { return }
        let selected = TemplateCategory.allCases.filter { selectedInterests.contains($0) }
        let rest = TemplateCategory.allCases.filter { !selectedInterests.contains($0) }
        appState.preferredCategories = selected + rest
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
            // Hero area — replace with real images before launch
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(AppTheme.Colors.secondaryBackground)

                VStack(spacing: 14) {
                    Image(systemName: "photo.on.rectangle.angled.fill")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(AppTheme.Colors.textQuaternary)
                    Text("Hero images go here")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textQuaternary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .frame(maxHeight: .infinity)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Page 2: Interests

private struct InterestsPage: View {
    @Binding var selectedInterests: Set<TemplateCategory>

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What are you into?")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("We'll personalise your home screen\nfor a better experience.")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineSpacing(3)
                }
                .padding(.top, 56)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(TemplateCategory.allCases) { category in
                        InterestCard(
                            category: category,
                            isSelected: selectedInterests.contains(category)
                        ) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if selectedInterests.contains(category) {
                                    selectedInterests.remove(category)
                                } else {
                                    selectedInterests.insert(category)
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
    let category: TemplateCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? AppTheme.Colors.accent.opacity(0.12)
                              : AppTheme.Colors.tertiaryBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: category.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textSecondary)
                }

                Text(category.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected
                          ? AppTheme.Colors.accent.opacity(0.06)
                          : AppTheme.Colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? AppTheme.Colors.accent : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Page 3: How It Works

private struct HowItWorksPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("How it works")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text("Three steps to your perfect creation.")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .padding(.top, 56)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            VStack(spacing: 0) {
                // Before
                HowItWorksCard(label: "BEFORE", icon: "camera.fill", color: AppTheme.Colors.textTertiary)

                HowItWorksConnector()

                // Prompt
                HStack(spacing: 12) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent)

                    Text("AI applies the magic...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.Colors.accent.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.Colors.accent.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                HowItWorksConnector()

                // After
                HowItWorksCard(label: "AFTER", icon: "photo.fill", color: AppTheme.Colors.accent)
            }

            Spacer()
        }
    }
}

private struct HowItWorksCard: View {
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.Colors.secondaryBackground)

            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundStyle(color)

                Text(label)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.Colors.textQuaternary)
            }
        }
        .frame(height: 110)
        .padding(.horizontal, 24)
    }
}

private struct HowItWorksConnector: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(AppTheme.Colors.separator)
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.vertical, 6)
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

                    Text("Your rating helps us grow\nand improve just for you.")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
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
