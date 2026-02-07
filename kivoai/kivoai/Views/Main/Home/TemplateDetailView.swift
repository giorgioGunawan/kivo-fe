//
//  TemplateDetailView.swift
//  kivoai
//
//  Content-first template detail with progressive disclosure.
//

import SwiftUI
import PhotosUI

struct TemplateDetailView: View {
    let template: Template
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var customPrompt: String = ""
    @State private var showAdvanced: Bool = false
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    private var canGenerate: Bool {
        let hasPhoto = !template.requiresPhoto || selectedImage != nil
        let hasCredits = appState.hasEnoughCredits(for: template.creditCost)
        let notBusy = !isGenerating
        return hasPhoto && hasCredits && notBusy
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // Header
                    headerSection
                        .padding(.top, 60) // Space for floating back button
                    
                    // Photo picker
                    if template.requiresPhoto {
                        photoSection
                    }
                    
                    // Hint
                    hintSection
                    
                    // Advanced (collapsed by default)
                    if template.showsAdvancedPrompt {
                        advancedSection
                    }
                    
                    Spacer()
                        .frame(height: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            // Floating Back Button
            backButton
        }
        .navigationBarHidden(true) // Hide the bulky system bar
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
        .alert("Generation Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            appState.tabBarHidden = true
        }
        .onDisappear {
            appState.tabBarHidden = false
        }
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button {
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
        .padding(.leading, AppTheme.Spacing.md)
        .padding(.top, 10)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Category pill
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: template.category.iconName)
                    .font(.system(size: 12, weight: .semibold))
                Text(template.category.title)
                    .font(AppTheme.Typography.caption.weight(.semibold))
            }
            .foregroundStyle(AppTheme.Colors.accent)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xxs)
            .background(AppTheme.Colors.accent.opacity(0.1))
            .clipShape(Capsule())
            
            Text(template.title)
                .font(AppTheme.Typography.title)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            
            Text(template.subtitle)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Your Photo")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                            .fill(AppTheme.Colors.background)
                            .frame(height: 180)
                            .overlay(
                                VStack(spacing: AppTheme.Spacing.sm) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 32, weight: .light))
                                        .foregroundStyle(AppTheme.Colors.textTertiary)
                                    
                                    Text("Tap to select a photo")
                                        .font(AppTheme.Typography.subheadline)
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                                    .foregroundStyle(AppTheme.Colors.separator)
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Hint Section
    
    private var hintSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Label("What to photograph", systemImage: "lightbulb")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(template.photographHint)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text("Example: \(template.exampleDescription)")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .italic()
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        }
    }
    
    // MARK: - Advanced Section
    
    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showAdvanced.toggle()
                }
            } label: {
                HStack {
                    Label("Advanced Options", systemImage: "slider.horizontal.3")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .rotationEffect(.degrees(showAdvanced ? 90 : 0))
                }
            }
            .buttonStyle(.plain)
            
            if showAdvanced {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Custom description (optional)")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    TextField("Add specific details...", text: $customPrompt, axis: .vertical)
                        .font(AppTheme.Typography.body)
                        .lineLimit(3...6)
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Credit info
            HStack {
                Text("🪙")
                    .font(.system(size: 14))
                
                Text("\(template.creditCost) credits")
                    .font(AppTheme.Typography.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                if !appState.hasEnoughCredits(for: template.creditCost) {
                    Text("Not enough credits")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.error)
                }
            }
            
            // Generate button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                startGeneration()
            }) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    if isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    
                    Text(isGenerating ? "Generating..." : "Generate")
                        .font(AppTheme.Typography.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(canGenerate ? LinearGradient.accentGradient : LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            }
            .disabled(!canGenerate)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.lg)
        .background(
            AppTheme.Colors.background
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Actions
    
    private func startGeneration() {
        guard canGenerate else { return }
        
        guard appState.consumeCredits(cost: template.creditCost) else {
            errorMessage = "Not enough credits. Upgrade to Pro or buy a pack."
            showError = true
            return
        }
        
        isGenerating = true
        
        var inputImageURL: URL? = nil
        if let image = selectedImage {
            inputImageURL = saveInputImage(image)
        }
        
        let prompt = customPrompt.isEmpty ? template.subtitle : "\(template.subtitle). \(customPrompt)"
        
        let job = GenerationJob(
            templateId: template.id,
            templateTitle: template.title,
            status: .queued,
            creditCost: template.creditCost,
            prompt: prompt,
            inputImageURL: inputImageURL
        )
        appState.addJob(job)
        
        Task {
            appState.updateJobStatus(jobId: job.id, status: .running(progress: nil))
            
            let request = GenerateImageRequest(
                prompt: prompt,
                templateId: template.id,
                inputImageURL: inputImageURL,
                estimatedCreditCost: template.creditCost
            )
            
            do {
                let result = try await appEnvironment.imageService.generateImage(request)
                appState.updateJobStatus(jobId: job.id, status: .completed(localURL: result.localImageURL))
                
                await MainActor.run {
                    isGenerating = false
                    dismiss()
                }
            } catch {
                appState.updateJobStatus(jobId: job.id, status: .failed(message: error.localizedDescription))
                
                await MainActor.run {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func saveInputImage(_ image: UIImage) -> URL? {
        let directory = FileManager.default.temporaryDirectory
        let filename = "input_\(UUID().uuidString).jpg"
        let fileURL = directory.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}

#Preview {
    NavigationStack {
        TemplateDetailView(template: Template.sampleTemplates[0])
            .environmentObject(AppState())
            .environmentObject(AppEnvironment())
    }
}
