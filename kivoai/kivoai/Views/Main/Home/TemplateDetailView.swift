//
//  TemplateDetailView.swift
//  kivoai
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
        ZStack {
            LinearGradient.kivoBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Template header
                    headerSection
                    
                    // Photo picker section
                    if template.requiresPhoto {
                        photoSection
                    }
                    
                    // What to photograph hint
                    hintSection
                    
                    // Advanced prompt section
                    if template.showsAdvancedPrompt {
                        advancedSection
                    }
                    
                    // Credit info
                    creditSection
                    
                    // Generate button
                    generateButton
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(template.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
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
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            HStack(spacing: 6) {
                Image(systemName: template.category.iconName)
                    .font(.system(size: 12, weight: .semibold))
                Text(template.category.title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(Color.kivoAccent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.kivoAccent.opacity(0.15))
            .clipShape(Capsule())
            
            Text(template.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(template.subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.kivoTextSecondary)
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Your Photo", systemImage: "camera.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.kivoCardBackground)
                            .frame(height: 200)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 40, weight: .light))
                                        .foregroundColor(Color.kivoTextSecondary)
                                    
                                    Text("Tap to select a photo")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.kivoTextSecondary)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.kivoAccent.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Hint Section
    
    private var hintSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What to photograph", systemImage: "lightbulb.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(template.photographHint)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.kivoTextPrimary)
                
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(Color.kivoTextTertiary)
                    
                    Text("Example: \(template.exampleDescription)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.kivoTextSecondary)
                        .italic()
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.kivoCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Advanced Section
    
    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showAdvanced.toggle()
                }
            } label: {
                HStack {
                    Label("Advanced Options", systemImage: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.kivoTextSecondary)
                }
            }
            
            if showAdvanced {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom description (optional)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.kivoTextSecondary)
                    
                    TextEditor(text: $customPrompt)
                        .font(.system(size: 14))
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.white)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color.kivoCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text("💡 A base prompt is always applied to ensure quality results")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kivoTextTertiary)
                }
            }
        }
    }
    
    // MARK: - Credit Section
    
    private var creditSection: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .font(.system(size: 16))
                .foregroundColor(Color.kivoCredits)
            
            Text("\(template.creditCost) credits per generation")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            if !appState.hasEnoughCredits(for: template.creditCost) {
                Text("Not enough credits")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.kivoError)
            }
        }
        .padding(16)
        .background(Color.kivoCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        Button(action: startGeneration) {
            HStack(spacing: 10) {
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(isGenerating ? "Generating..." : "Generate")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                canGenerate
                    ? AnyShapeStyle(LinearGradient(
                        colors: [Color.kivoAccent, Color.kivoPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    : AnyShapeStyle(Color.gray.opacity(0.5))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!canGenerate)
    }
    
    // MARK: - Generation Logic
    
    private func startGeneration() {
        guard canGenerate else { return }
        
        // Consume credits
        guard appState.consumeCredits(cost: template.creditCost) else {
            errorMessage = "Not enough credits. Upgrade to Pro or buy a pack."
            showError = true
            return
        }
        
        isGenerating = true
        
        // Save input image if provided
        var inputImageURL: URL? = nil
        if let image = selectedImage {
            inputImageURL = saveInputImage(image)
        }
        
        // Build prompt
        let prompt = customPrompt.isEmpty ? template.subtitle : "\(template.subtitle). \(customPrompt)"
        
        // Create job
        let job = GenerationJob(
            templateId: template.id,
            templateTitle: template.title,
            status: .queued,
            creditCost: template.creditCost,
            prompt: prompt,
            inputImageURL: inputImageURL
        )
        appState.addJob(job)
        
        // Start generation
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
