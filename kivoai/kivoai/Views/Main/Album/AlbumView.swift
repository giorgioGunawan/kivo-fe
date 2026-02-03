//
//  AlbumView.swift
//  kivoai
//

import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var appState: AppState
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.kivoBackground
                    .ignoresSafeArea()
                
                if appState.generationJobs.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(appState.generationJobs) { job in
                                NavigationLink(destination: GeneratedImageDetailView(job: job)) {
                                    AlbumItemView(job: job)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Album")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.kivoTextPrimary)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.kivoAccent.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "photo.stack")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color.kivoAccent)
            }
            
            VStack(spacing: 8) {
                Text("No creations yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.kivoTextPrimary)
                
                Text("Your AI-generated images will appear here")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                appState.showingCustomCreation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                    Text("Create your first")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.kivoAccent, Color.kivoPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(40)
    }
}

struct AlbumItemView: View {
    let job: GenerationJob
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image area
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.kivoCardBackground)
                    .aspectRatio(1, contentMode: .fit)
                
                switch job.status {
                case .completed(let localURL):
                    if let image = loadImage(from: localURL) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        imagePlaceholder
                    }
                    
                case .queued:
                    VStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(Color.kivoTextSecondary)
                        Text("Queued")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.kivoTextSecondary)
                    }
                    
                case .running(let progress):
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.kivoAccent)
                        
                        if let p = progress {
                            Text("\(Int(p * 100))%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.kivoTextSecondary)
                        } else {
                            Text("Generating...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.kivoTextSecondary)
                        }
                    }
                    
                case .failed:
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(Color.kivoError)
                        Text("Failed")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.kivoError)
                    }
                    
                case .idle:
                    imagePlaceholder
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(job.isCustom ? "Custom" : job.templateTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.kivoTextPrimary)
                    .lineLimit(1)
                
                Text(job.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.kivoTextTertiary)
            }
        }
        .padding(8)
        .background(Color.kivoCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var imagePlaceholder: some View {
        Image(systemName: "photo")
            .font(.system(size: 30, weight: .light))
            .foregroundColor(Color.kivoTextTertiary)
    }
    
    private func loadImage(from url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

#Preview {
    AlbumView()
        .environmentObject({
            let state = AppState()
            // Add sample jobs for preview
            state.addJob(GenerationJob(
                templateId: "test",
                templateTitle: "Mugshot",
                status: .running(progress: 0.6),
                creditCost: 10,
                prompt: "Test"
            ))
            state.addJob(GenerationJob(
                templateId: nil,
                templateTitle: "Custom",
                status: .failed(message: "Network error"),
                creditCost: 20,
                prompt: "Test"
            ))
            return state
        }())
}
