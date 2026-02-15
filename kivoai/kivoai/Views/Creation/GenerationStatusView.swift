//
//  GenerationStatusView.swift
//  kivoai
//

import SwiftUI

struct GenerationStatusView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let jobId: UUID

    @State private var showDismissArea: Bool = false

    private var job: GenerationJob? {
        appState.generationJobs.first(where: { $0.id == jobId })
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            Text("Kivo AI")
                .font(.system(size: 68, weight: .black, design: .rounded))
                .foregroundStyle(LinearGradient.accentGradient)
                .padding(.bottom, 48)

            // Input image + spinner
            ZStack {
                if let inputURL = job?.inputImageURL,
                   let data = try? Data(contentsOf: inputURL),
                   let uiImage = UIImage(data: data) {
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

            // Status copy
            Text("Generating your image")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.top, 32)

            Spacer()

            // Dismiss area — appears after a few seconds
            if showDismissArea {
                VStack(spacing: 14) {
                    Text("It'll be waiting for you in the Library")
                        .font(AppTheme.Typography.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Button {
                        appState.activeJobId = nil
                        appState.showingCustomCreation = false
                    } label: {
                        Text("Keep Exploring")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AppTheme.Colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, AppTheme.Spacing.xl)
            } else {
                Spacer().frame(height: 100)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring()) {
                    showDismissArea = true
                }
            }
        }
        .onChange(of: job?.status) { _, newStatus in
            if case .completed = newStatus {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    appState.activeJobId = nil
                }
            } else if case .failed = newStatus {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
