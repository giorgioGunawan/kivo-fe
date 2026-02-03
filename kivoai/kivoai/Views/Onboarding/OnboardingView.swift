//
//  OnboardingView.swift
//  kivoai
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: OnboardingStep = .value
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.kivoBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
                    .padding()
                }
                
                // Page content
                TabView(selection: $currentStep) {
                    ForEach(OnboardingStep.allCases) { step in
                        OnboardingStepView(step: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(OnboardingStep.allCases) { step in
                        Circle()
                            .fill(step == currentStep ? Color.kivoAccent : Color.kivoTextTertiary)
                            .frame(width: 8, height: 8)
                            .scaleEffect(step == currentStep ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .padding(.bottom, 20)
                
                // Action button
                Button(action: handleNextAction) {
                    Text(currentStep.isLast ? "Get Started" : "Next")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.kivoAccent, Color.kivoPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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

struct OnboardingStepView: View {
    let step: OnboardingStep
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color.kivoAccent.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 30)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kivoAccent.opacity(0.3), Color.kivoPink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: step.iconName)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.kivoTextSecondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            
            // Text content
            VStack(spacing: 16) {
                Text(step.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(step.subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(textOpacity)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                textOpacity = 1.0
            }
        }
        .onDisappear {
            iconScale = 0.5
            iconOpacity = 0
            textOpacity = 0
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
