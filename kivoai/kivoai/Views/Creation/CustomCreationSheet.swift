//
//  CustomCreationSheet.swift
//  kivoai
//
//  Ultra-refined, minimal creation interface.
//

import SwiftUI
import PhotosUI

struct CustomCreationSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var cameraService = CameraService()
    
    @State private var prompt: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    @State private var isTextFieldActive: Bool = false
    
    private let creditCost = 20
    
    private var canGenerate: Bool {
        let hasPrompt = !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = selectedImage != nil
        let hasCredits = appState.hasEnoughCredits(for: creditCost)
        return hasPrompt && hasImage && hasCredits && !isGenerating
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            if selectedImage != nil {
                postCaptureContent
            } else {
                cameraContent
            }
        }
        .onAppear {
            cameraService.onPhotoCaptured = { img in
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                self.selectedImage = img
                self.cameraService.stopSession()
            }
            #if !targetEnvironment(simulator)
            cameraService.checkPermissions()
            #endif
        }
        .onDisappear {
            cameraService.stopSession()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = img
                        cameraService.stopSession()
                    }
                }
            }
        }
    }
    
    // MARK: - Post Capture
    private var postCaptureContent: some View {
        VStack(spacing: 0) {
            headerBar
            
            if let img = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    Button {
                        selectedImage = nil
                        selectedPhotoItem = nil
                        cameraService.startSession()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 4)
                    }
                    .padding(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            
            Spacer(minLength: 16)
            
            // Input area with responsive text field
            responsiveInputBar
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Camera View
    private var cameraContent: some View {
        VStack(spacing: 0) {
            headerBar
            
            // Camera preview - slightly more square aspect ratio
            Group {
                if cameraService.isPermissionGranted {
                    CameraPreview(session: cameraService.session)
                        .aspectRatio(3/4, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                } else {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(AppTheme.Colors.secondaryBackground)
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(AppTheme.Colors.textQuaternary)
                                Text("Camera access required")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(AppTheme.Colors.textQuaternary)
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // More spacing before capture buttons
            captureBar
                .padding(.top, 24)
                .padding(.bottom, 32)
        }
    }
    
    // MARK: - Components
    private var headerBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(12)
                    .background(Circle().fill(AppTheme.Colors.secondaryBackground))
            }
            
            Spacer()
            
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.credits)
                Text("\(creditCost)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(AppTheme.Colors.secondaryBackground))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // Responsive input bar with instant tap response
    private var responsiveInputBar: some View {
        HStack(alignment: .center, spacing: 10) {
            // Text input with overlay for instant tap
            ZStack {
                TextField("Describe your vision...", text: $prompt, axis: .vertical)
                    .font(.system(size: 15))
                    .lineLimit(1...4)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(uiColor: .systemGray6))
                    )
            }
            .frame(minHeight: 48)
            .contentShape(Rectangle())
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
            // Send button - same height as text field
            Button(action: startGeneration) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(canGenerate ? AppTheme.Colors.accent : Color(uiColor: .systemGray5))
                        .frame(width: 48, height: 48)
                    
                    if isGenerating {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(canGenerate ? .white : Color(uiColor: .systemGray3))
                    }
                }
            }
            .disabled(!canGenerate)
        }
    }
    
    private var captureBar: some View {
        HStack {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Capture button with darker purple gradient
            Button {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                cameraService.capturePhoto()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.25), lineWidth: 3)
                        .frame(width: 76, height: 76)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.2, blue: 0.8),
                                    Color(red: 0.35, green: 0.1, blue: 0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.purple.opacity(0.4), radius: 8, y: 4)
                }
            }
            
            Spacer()
            
            Button {
                cameraService.switchCamera()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 44)
    }
    
    // MARK: - Actions
    private func startGeneration() {
        guard canGenerate else { return }
        guard appState.consumeCredits(cost: creditCost) else {
            errorMessage = "Not enough credits."
            showError = true
            return
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isGenerating = true
        
        let inputURL = selectedImage.flatMap { saveInputImage($0) }
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let job = GenerationJob(
            templateId: nil,
            templateTitle: "Custom",
            status: .queued,
            creditCost: creditCost,
            prompt: trimmedPrompt,
            inputImageURL: inputURL
        )
        appState.addJob(job)
        
        Task {
            appState.updateJobStatus(jobId: job.id, status: .running(progress: nil))
            
            let request = GenerateImageRequest(
                prompt: trimmedPrompt,
                templateId: nil,
                inputImageURL: inputURL,
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
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("input_\(UUID().uuidString).jpg")
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        try? data.write(to: url)
        return url
    }
}
