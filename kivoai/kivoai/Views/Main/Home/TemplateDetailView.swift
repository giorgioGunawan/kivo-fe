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
    @State private var customPrompt: String
    @State private var selectedStyleIndex: Int = 0
    @State private var isGenerating: Bool = false
    @State private var showingExtraCreditsSheet: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    @State private var startedJobId: UUID? = nil
    @State private var generationWasCompleted = false
    @FocusState private var promptFocused: Bool

    init(template: Template) {
        self.template = template
        let initialPrompt = template.styleVariants.first?.prompt ?? template.basePrompt
        self._customPrompt = State(initialValue: initialPrompt)
    }

    private var canGenerate: Bool {
        let hasPhoto = !template.requiresPhoto || selectedImage != nil
        let hasCredits = appState.hasEnoughCredits(for: template.creditCost)
        let notBusy = !isGenerating
        return hasPhoto && hasCredits && notBusy
    }

    private var currentVariant: TemplateStyleVariant? {
        guard !template.styleVariants.isEmpty else { return nil }
        return template.styleVariants[selectedStyleIndex]
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        // Photo picker
                        Spacer().frame(height: 44)
                        if template.requiresPhoto {
                            photoSection
                                .frame(maxWidth: .infinity)
                        }

                        // Style pills (only for templates with variants)
                        if !template.styleVariants.isEmpty {
                            stylePillsSection
                                .padding(.horizontal, -AppTheme.Spacing.lg)
                        }

                        // Always-visible prompt editor
                        promptSection
                            .id("prompt")

                        // Extra space when editing so there's room to scroll up fully
                        Spacer()
                            .frame(height: promptFocused ? 260 : AppTheme.Spacing.xl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
                .onChange(of: promptFocused) { _, focused in
                    if focused {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo("prompt", anchor: .bottom)
                            }
                        }
                    }
                }
            }

            // Floating Back Button
            backButton
        }
        .navigationBarHidden(true)
        .enableSwipeBack()
        .safeAreaInset(edge: .bottom) {
            if promptFocused {
                doneButton
            } else {
                bottomBar
            }
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
        .sheet(isPresented: $showingExtraCreditsSheet) {
            ExtraCreditsSheet()
                .environmentObject(appState)
                .environmentObject(appEnvironment)
        }
        .onChange(of: startedJob?.status) { _, newStatus in
            if case .completed = newStatus {
                generationWasCompleted = true
            }
        }
        .onChange(of: appState.activeJobId) { _, newId in
            if newId == nil && startedJobId != nil {
                dismiss()
            }
        }
        .onAppear {
            appState.tabBarHidden = true
        }
        .onDisappear {
            appState.tabBarHidden = false
        }
    }

    @State private var showingCamera = false

    private var startedJob: GenerationJob? {
        guard let jid = startedJobId else { return nil }
        return appState.generationJobs.first(where: { $0.id == jid })
    }

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

    private var exampleImageName: String {
        if let variant = currentVariant, !variant.afterImageName.isEmpty {
            return variant.afterImageName
        }
        return template.afterImageName
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 235, height: 255)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

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
            } else if !exampleImageName.isEmpty,
                      let exampleImg = UIImage(named: exampleImageName) {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: exampleImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 235, height: 255)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Title overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 90)
                    .clipShape(
                        UnevenRoundedRectangle(
                            bottomLeadingRadius: 20,
                            bottomTrailingRadius: 20
                        )
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(template.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Example")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(14)
                }
                .frame(width: 235, height: 255)
                .animation(.easeInOut(duration: 0.3), value: exampleImageName)
                .id(exampleImageName)
                .transition(.opacity)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.Colors.secondaryBackground)
                    .frame(width: 235, height: 255)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AppTheme.Colors.textQuaternary)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedStyleIndex)
    }

    // MARK: - Style Pills Section

    private var stylePillsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(Array(template.styleVariants.enumerated()), id: \.element.id) { index, variant in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedStyleIndex = index
                            customPrompt = variant.prompt
                        }
                    } label: {
                        Text(variant.title)
                            .font(.system(size: 14, weight: selectedStyleIndex == index ? .semibold : .regular))
                            .foregroundStyle(selectedStyleIndex == index ? .white : AppTheme.Colors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                selectedStyleIndex == index
                                    ? AnyShapeStyle(Color(UIColor.darkGray))
                                    : AnyShapeStyle(AppTheme.Colors.fill)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedStyleIndex == index ? Color.clear : AppTheme.Colors.opaqueSeparator,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, 2)
        }
    }

    // MARK: - Prompt Section

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Prompt")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.5)

            if template.id == "people_celebrity" {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.Colors.accent)
                    Text("Customize it: Add any celebrity you want")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.accent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $customPrompt)
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100, maxHeight: 200)
                    .padding(14)
                    .focused($promptFocused)

                if !promptFocused {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        promptFocused = true
                    } label: {
                        Image("thickPencil")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(Color(UIColor.label))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(UIColor.secondarySystemBackground)))
                            .overlay(Circle().stroke(Color(UIColor.opaqueSeparator), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .transition(.opacity.animation(.easeInOut(duration: 0.15)))
                }
            }
            .background(AppTheme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        promptFocused ? AppTheme.Colors.accent : Color(UIColor.opaqueSeparator),
                        lineWidth: promptFocused ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: promptFocused)
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
                        .background(AppTheme.Colors.fill)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                                .stroke(AppTheme.Colors.opaqueSeparator, lineWidth: 1.5)
                        )
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
                            if appState.isProSubscriber {
                                showingExtraCreditsSheet = true
                            } else {
                                appState.showingPaywall = true
                            }
                        } label: {
                            Text(appState.isProSubscriber ? "Top up →" : "Get Pro →")
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

    // MARK: - Done Button (shown above keyboard while editing prompt)

    private var doneButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            promptFocused = false
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        } label: {
            Text("Done")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(LinearGradient.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
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

        let prompt = customPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? (currentVariant?.prompt ?? template.basePrompt)
            : customPrompt

        let job = GenerationJob(
            templateId: template.id,
            templateTitle: template.title,
            status: .queued,
            creditCost: template.creditCost,
            prompt: prompt,
            inputImageURL: inputImageURL
        )
        appState.addJob(job)
        startedJobId = job.id
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
                // Step 1: Create the backend job and store the ID immediately
                let backendJobId = try await appEnvironment.imageService.createJob(request)
                appState.updateJobBackendId(jobId: job.id, backendJobId: backendJobId)
                
                // Step 2: Poll for completion
                let result = try await appEnvironment.imageService.checkJobStatus(backendJobId: backendJobId)
                
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
