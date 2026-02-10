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
                        .padding(.top, 60)
                    
                    // Photo picker
                    if template.requiresPhoto {
                        photoSection
                    }
                    
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
        .navigationBarHidden(true)
        .enableSwipeBack()
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingCamera) {
            CameraServiceView(image: $selectedImage, creditCost: template.creditCost)
        }
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
        .fullScreenCover(item: $appState.activeJobId) { jobId in
            GenerationStatusView(jobId: jobId)
        }
        .onAppear {
            appState.tabBarHidden = true
        }
        .onDisappear {
            appState.tabBarHidden = false
        }
    }
    
    @State private var showingCamera = false
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.leading, AppTheme.Spacing.md)
        .padding(.top, 10)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(template.title)
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }
    
    // MARK: - Photo Section

    private var photoSection: some View {
        Group {
            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 24))

                    Button {
                        selectedImage = nil
                        selectedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 4)
                    }
                    .padding(10)
                }
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.Colors.secondaryBackground)
                    .frame(height: 180)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(AppTheme.Colors.textQuaternary)
                            Text(template.photographHint)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }
            }
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
                    Label("Custom prompt (Optional)", systemImage: "sparkles")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textQuaternary)
                        .rotationEffect(.degrees(showAdvanced ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if showAdvanced {
                TextField("Add specific details...", text: $customPrompt, axis: .vertical)
                    .font(.system(size: 15))
                    .lineLimit(2...4)
                    .padding(16)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if template.requiresPhoto && selectedImage == nil {
                // No photo yet — primary CTAs to add one
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showingCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                }
                .buttonStyle(.plain)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Upload from Library", systemImage: "photo.fill")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.Colors.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                // Photo ready (or not required) — show credit info + generate
                HStack {
                    HStack(spacing: 4) {
                        Text("🪙")
                            .font(.system(size: 14))
                        Text("\(template.creditCost) credits")
                            .font(AppTheme.Typography.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                    }

                    Spacer()

                    if !appState.hasEnoughCredits(for: template.creditCost) {
                        Button {
                            appState.showingPaywall = true
                        } label: {
                            Text("Get credits →")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    startGeneration()
                }) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        if isGenerating {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(isGenerating ? "Generating..." : "Generate")
                            .font(AppTheme.Typography.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canGenerate ? LinearGradient.accentGradient : LinearGradient(colors: [Color.gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                    .contentShape(Rectangle())
                }
                .disabled(!canGenerate)
                .buttonStyle(.plain)
            }
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
        
        var inputImageURL: URL? = nil
        if let image = selectedImage {
            inputImageURL = saveInputImage(image)
        }
        
        let prompt = customPrompt.isEmpty ? template.basePrompt : "\(template.basePrompt). \(customPrompt)"
        
        let job = GenerationJob(
            templateId: template.id,
            templateTitle: template.title,
            status: .queued,
            creditCost: template.creditCost,
            prompt: prompt,
            inputImageURL: inputImageURL
        )
        appState.addJob(job)
        appState.activeJobId = job.id
        
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
                // Convert full URL to relative path for persistence
                let relativePath = "Creations/" + result.localImageURL.lastPathComponent
                appState.updateJobStatus(jobId: job.id, status: .completed(relativePath: relativePath))
                await appState.refreshCreditBalance(apiClient: appEnvironment.apiClient)
            } catch {
                let message: String
                if let apiError = error as? APIError, case .insufficientCredits = apiError {
                    message = "Insufficient credits. Please upgrade to Pro."
                    appState.showingPaywall = true
                } else {
                    message = error.localizedDescription
                }
                
                appState.updateJobStatus(jobId: job.id, status: .failed(message: message))
                await appState.refreshCreditBalance(apiClient: appEnvironment.apiClient)
            }
        }
    }
    
    private func saveInputImage(_ image: UIImage) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let creationsURL = documentsURL.appendingPathComponent("Creations", isDirectory: true)
        
        if !fileManager.fileExists(atPath: creationsURL.path) {
            try? fileManager.createDirectory(at: creationsURL, withIntermediateDirectories: true)
        }
        
        let fileURL = creationsURL.appendingPathComponent("input_\(UUID().uuidString).jpg")
        
        // Resize to a reasonable dimension for AI (max 1024px)
        guard let resizedImage = image.resized(to: 1024),
              let data = resizedImage.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
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
