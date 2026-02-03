//
//  CustomCreationSheet.swift
//  kivoai
//

import SwiftUI
import PhotosUI

struct CustomCreationSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    
    @State private var prompt: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    private let creditCost = 20
    
    private var canGenerate: Bool {
        let hasPrompt = !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasCredits = appState.hasEnoughCredits(for: creditCost)
        let notBusy = !isGenerating
        return hasPrompt && hasCredits && notBusy
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.kivoBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection
                        
                        // Photo picker (optional)
                        photoSection
                        
                        // Prompt input
                        promptSection
                        
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.kivoTextSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Custom Creation")
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
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kivoAccent.opacity(0.3), Color.kivoPink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text("Create anything")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Describe what you want to see and let AI bring it to life")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.kivoTextSecondary)
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Reference Photo", systemImage: "camera.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("(Optional)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.kivoTextTertiary)
            }
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    if let image = selectedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            Button {
                                selectedImage = nil
                                selectedPhotoItem = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .padding(8)
                        }
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(Color.kivoTextSecondary)
                            
                            Text("Add a reference photo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.kivoTextSecondary)
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.kivoCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.kivoAccent.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6]))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Prompt Section
    
    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Describe your creation", systemImage: "text.bubble.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $prompt)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .frame(minHeight: 120)
                    .padding(16)
                    .background(Color.kivoCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                if prompt.isEmpty {
                    Text("E.g., A photo of me as a superhero flying over New York City at sunset...")
                        .font(.system(size: 15))
                        .foregroundColor(Color.kivoTextTertiary)
                        .padding(20)
                        .allowsHitTesting(false)
                }
            }
            
            Text("\(prompt.count) characters")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.kivoTextTertiary)
        }
    }
    
    // MARK: - Credit Section
    
    private var creditSection: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .font(.system(size: 16))
                .foregroundColor(Color.kivoCredits)
            
            Text("\(creditCost) credits for custom creation")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            if !appState.hasEnoughCredits(for: creditCost) {
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.showingPaywall = true
                    }
                } label: {
                    Text("Get credits")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.kivoAccent)
                }
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
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(isGenerating ? "Creating magic..." : "Generate")
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
        guard appState.consumeCredits(cost: creditCost) else {
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
        
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create job
        let job = GenerationJob(
            templateId: nil, // Custom creation
            templateTitle: "Custom",
            status: .queued,
            creditCost: creditCost,
            prompt: trimmedPrompt,
            inputImageURL: inputImageURL
        )
        appState.addJob(job)
        
        // Start generation
        Task {
            appState.updateJobStatus(jobId: job.id, status: .running(progress: nil))
            
            let request = GenerateImageRequest(
                prompt: trimmedPrompt,
                templateId: nil,
                inputImageURL: inputImageURL,
                estimatedCreditCost: creditCost
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
        let filename = "custom_input_\(UUID().uuidString).jpg"
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
    CustomCreationSheet()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
