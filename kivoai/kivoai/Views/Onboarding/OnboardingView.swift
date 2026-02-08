//
//  OnboardingView.swift
//  kivoai
//
//  Calm, spacious onboarding with minimal visual noise.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: OnboardingStep = .value
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip
                HStack {
                    Spacer()
                    Button {
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                            .frame(height: 44)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                // Content
                TabView(selection: $currentStep) {
                    ForEach(OnboardingStep.allCases) { step in
                        OnboardingStepView(step: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Indicators
                HStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(OnboardingStep.allCases) { step in
                        Capsule()
                            .fill(step == currentStep ? AppTheme.Colors.accent : AppTheme.Colors.separator)
                            .frame(width: step == currentStep ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.lg)
                
                // CTA
                Button(action: {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                    handleNextAction()
                }) {
                    Text(currentStep.isLast ? "Get Started" : "Continue")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
    }
    
    private func handleNextAction() {
        if currentStep.isLast {
            completeOnboarding()
        } else {
            withAnimation(.spring(response: 0.4)) {
                if let nextIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
                   nextIndex + 1 < OnboardingStep.allCases.count {
                    currentStep = OnboardingStep.allCases[nextIndex + 1]
                }
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appState.completeOnboarding()
        }
    }
}

// MARK: - Step View

struct OnboardingStepView: View {
    let step: OnboardingStep
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: step.iconName)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
            
            // Text
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(step.title)
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(step.subtitle)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }
            .opacity(isVisible ? 1 : 0)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
