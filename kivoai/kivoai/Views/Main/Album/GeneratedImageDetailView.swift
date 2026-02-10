//
//  GeneratedImageDetailView.swift
//  kivoai
//
//  Clean image detail with content-first layout.
//

import SwiftUI

struct GeneratedImageDetailView: View {
    let job: GenerationJob
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Space for floating back button
                    Color.clear.frame(height: safeAreaTopPadding + 64)
                    
                    // Image
                    mainImageSection
                        .padding(.horizontal, 16) // "Less horizontal padding"
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Action Row
                        // Placed high up for accessibility, classic iOS styling
                        actionRow
                        
                        // Title & Prompt Section
                        // Combined as requested: "Instead of 'Prompt'... put the title"
                        VStack(alignment: .leading, spacing: 12) {
                            if !job.isCustom {
                                Text(job.templateTitle)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(AppTheme.Colors.textPrimary)
                            }

                            Text("Prompt: \(job.prompt)")
                                .font(.body)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppTheme.Colors.secondaryBackground.opacity(0.5))
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Floating Back Button (Restored to previous style)
            backButton
            
            // Saved Feedback Notice
            if showingSaveFeedback {
                savedFeedbackBadge
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.container, edges: .top)
        .enableSwipeBack()
        .alert("Delete Creation?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                performDelete()
            }
        } message: {
            Text("This will permanently remove this image from your library.")
        }
        .onAppear {
            appState.tabBarHidden = true
        }
        .onDisappear {
            appState.tabBarHidden = false
        }
    }
    
    @State private var showingSaveFeedback = false
    @State private var showingDeleteConfirmation = false
    
    private var savedFeedbackBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Saved to Photos")
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .frame(maxWidth: .infinity)
        .padding(.top, safeAreaTopPadding + 8)
    }
    
    // MARK: - Back Button
    
    // Restored exactly as it was "before" (per user request)
    private var backButton: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.background)
                        .shadow(color: AppTheme.Shadow.soft, radius: 8, x: 0, y: 2)
                )
        }
        .padding(.leading, 16)
        .padding(.top, safeAreaTopPadding + 10) // Dynamic safe area handling
    }
    
    private var safeAreaTopPadding: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top
        }
        return 47 // Default generic top safe area
    }
    
    // MARK: - Image
    
    private var mainImageSection: some View {
        ZStack {
            switch job.status {
            case .completed(let path):
                 let url = FileUtils.getURL(for: path)
                 if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else {
                    statusPlaceholder(icon: "photo", text: "Image not found")
                }
            case .queued:
                statusPlaceholder(icon: "clock", text: "In queue...")
            case .running:
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Generating...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            case .failed(let message):
                statusPlaceholder(icon: "exclamationmark.triangle", text: "Failed", subtext: message)
            case .idle:
                statusPlaceholder(icon: "photo", text: "Waiting...")
            }
        }
        .aspectRatio(1.0, contentMode: .fit) // Square placeholder, adjusts for image
    }
    
    private func statusPlaceholder(icon: String, text: String, subtext: String? = nil) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.headline)
                .foregroundStyle(.primary)
            if let subtext = subtext {
                Text(subtext)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(minHeight: 300)
    }
    
    // MARK: - Actions
    
    private var actionRow: some View {
        HStack(spacing: 12) {
            // Save
            ActionButton(
                label: "Save",
                icon: "square.and.arrow.down",
                color: AppTheme.Colors.textPrimary
            ) {
                saveImage()
            }
            
            // Share
            ActionButton(
                label: "Share",
                icon: "square.and.arrow.up",
                color: AppTheme.Colors.textPrimary
            ) {
                shareImage()
            }
            
            // Delete
            ActionButton(
                label: nil,
                icon: "trash",
                color: .red
            ) {
                showingDeleteConfirmation = true
            }
            .frame(width: 54)
        }
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let label: String?
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                if let label = label {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.Colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(ActionButtonStyle())
    }
}

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension GeneratedImageDetailView {
    
    // MARK: - Handlers
    
    private func saveImage() {
        if let url = job.outputImageURL,
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            withAnimation(.spring()) {
                showingSaveFeedback = true
            }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Hide feedback after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showingSaveFeedback = false
                }
            }
        }
    }
    
    private func shareImage() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if let url = job.outputImageURL {
            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(av, animated: true, completion: nil)
            }
        }
    }
    
    private func deleteImage() {
        showingDeleteConfirmation = true
    }
    
    private func performDelete() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        appState.deleteJob(job)
        dismiss()
    }
}
