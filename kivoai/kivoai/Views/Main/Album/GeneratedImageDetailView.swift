//
//  GeneratedImageDetailView.swift
//  kivoai
//

import SwiftUI

struct GeneratedImageDetailView: View {
    let job: GenerationJob
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient.kivoBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Main image
                    imageSection
                    
                    // Info section
                    infoSection
                    
                    // Action buttons
                    actionButtons
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(job.isCustom ? "Custom Creation" : job.templateTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Image Section
    
    private var imageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.kivoCardBackground)
                .aspectRatio(1, contentMode: .fit)
            
            switch job.status {
            case .completed(let localURL):
                if let image = loadImage(from: localURL) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    placeholderContent(icon: "photo", text: "Image not found")
                }
                
            case .queued:
                placeholderContent(icon: "clock", text: "Waiting in queue...")
                
            case .running(let progress):
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(Color.kivoAccent)
                    
                    if let p = progress {
                        Text("\(Int(p * 100))% complete")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.kivoTextSecondary)
                    } else {
                        Text("Generating your image...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.kivoTextSecondary)
                    }
                }
                
            case .failed(let message):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(Color.kivoError)
                    
                    Text("Generation Failed")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.kivoTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                
            case .idle:
                placeholderContent(icon: "photo", text: "No image")
            }
        }
    }
    
    private func placeholderContent(icon: String, text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50, weight: .light))
                .foregroundColor(Color.kivoTextTertiary)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.kivoTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(spacing: 16) {
            InfoRow(label: "Type", value: job.isCustom ? "Custom Creation" : "Template")
            
            if !job.isCustom {
                InfoRow(label: "Template", value: job.templateTitle)
            }
            
            InfoRow(label: "Created", value: job.createdAt.formatted(date: .long, time: .shortened))
            
            InfoRow(label: "Credits Used", value: "\(job.creditCost)")
            
            InfoRow(label: "Status", value: statusText, valueColor: statusColor)
        }
        .padding(20)
        .background(Color.kivoCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var statusText: String {
        switch job.status {
        case .idle: return "Idle"
        case .queued: return "Queued"
        case .running: return "Generating"
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }
    
    private var statusColor: Color {
        switch job.status {
        case .completed: return Color.kivoSuccess
        case .failed: return Color.kivoError
        case .running: return Color.kivoAccent
        default: return Color.kivoTextSecondary
        }
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private var actionButtons: some View {
        if case .completed(let localURL) = job.status,
           let image = loadImage(from: localURL) {
            HStack(spacing: 16) {
                // Save to Photos
                ShareLink(item: Image(uiImage: image), preview: SharePreview("Kivo Creation", image: Image(uiImage: image))) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.kivoAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Save button
                Button {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Save")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.kivoCardBackgroundLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private func loadImage(from url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.kivoTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    NavigationStack {
        GeneratedImageDetailView(job: GenerationJob(
            templateId: "test",
            templateTitle: "Mugshot Madness",
            status: .failed(message: "Network connection lost"),
            creditCost: 10,
            prompt: "Test prompt"
        ))
    }
}
