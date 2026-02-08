//
//  GenerationStatusView.swift
//  kivoai
//
//  Refined generation status screen with progress and tips.
//

import SwiftUI

struct GenerationStatusView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    let jobId: UUID
    
    @State private var timeRemaining: Int = 30
    @State private var tipIndex: Int = 0
    @State private var showContinueButton: Bool = false
    
    private let tips = [
        "Kivo works best with well-lit photos.",
        "Try different templates for unique styles.",
        "You can find all your creations in the Library.",
        "Be specific with your custom prompts!",
        "Quality takes time, usually about 30 seconds."
    ]
    
    private var job: GenerationJob? {
        appState.generationJobs.first(where: { $0.id == jobId })
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            
            // Header
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Generating Your Vision")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text(job?.templateTitle ?? "Custom Creation")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            
            // Thumbnail & Progress
            ZStack {
                if let inputURL = job?.inputImageURL, let data = try? Data(contentsOf: inputURL), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                .fill(.black.opacity(0.4))
                        )
                } else {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                        .fill(AppTheme.Colors.secondaryBackground)
                        .frame(width: 200, height: 200)
                }
                
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
            .shadow(color: AppTheme.Shadow.soft, radius: 20, x: 0, y: 10)
            
            // Status Info
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Usually takes ~20–40 seconds")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                if let prompt = job?.prompt {
                    Text("\"\(prompt)\"")
                        .font(AppTheme.Typography.body)
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .lineLimit(3)
                }
            }
            
            Spacer()
            
            // Tips
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("PRO TIP")
                    .font(AppTheme.Typography.caption.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.accent)
                
                Text(tips[tipIndex])
                    .font(AppTheme.Typography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .id(tipIndex)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            .frame(height: 80)
            
            Spacer()
            
            // Continue Button (Shows after 3 seconds)
            if showContinueButton {
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("You can leave this screen.\nWe'll notify you when it's ready.")
                        .font(AppTheme.Typography.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Continue Browsing")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AppTheme.Colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            } else {
                Spacer().frame(height: 100)
            }
        }
        .padding()
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            startTimer()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onChange(of: job?.status) { oldStatus, newStatus in
            if case .completed = newStatus {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                // Auto dismiss on success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else if case .failed = newStatus {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation {
                tipIndex = (tipIndex + 1) % tips.count
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.spring()) {
                showContinueButton = true
            }
        }
    }
}
