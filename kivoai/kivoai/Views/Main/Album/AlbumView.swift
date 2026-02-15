//
//  AlbumView.swift
//  kivoai
//
//  Grid view for generated creations, using native navigation.
//

import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var appState: AppState
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        Text("Library")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Spacer()
                        if !appState.generationJobs.isEmpty {
                            persistenceWarning
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.md)

                    if appState.generationJobs.isEmpty {
                        emptyState
                            .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                            ForEach(appState.generationJobs) { job in
                                NavigationLink(destination: GeneratedImageDetailView(job: job)) {
                                    AlbumItemView(job: job)
                                }
                                .buttonStyle(AlbumButtonStyle())
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.md)
                        .padding(.bottom, 120)
                    }
                }
            }
            .background(AppTheme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var persistenceWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.Colors.textSecondary)

            VStack(alignment: .leading, spacing: 0) {
                Text("Only the last 20 creations are stored.")
                Text("Save to Photos to avoid losing them.")
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppTheme.Colors.secondaryBackground)
        )
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "photo.stack")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("No creations yet")
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text("Your creation will appear here")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                appState.showingCustomCreation = true
            } label: {
                Label("Create Something", systemImage: "sparkles")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.Spacing.xl)
    }
}

// MARK: - Album Item

struct AlbumItemView: View {
    let job: GenerationJob
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Strictly square image container
            // We use Color.clear with aspectRatio(1) to define the square shape based on column width
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    GeometryReader { geo in
                        imageContent
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                )
                .background(AppTheme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            Text(job.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .padding(.horizontal, 2)
        }
    }
    
    @ViewBuilder
    private var imageContent: some View {
        switch job.status {
        case .completed(let path):
            let url = FileUtils.getURL(for: path)
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderIcon("photo")
            }
            
        case .queued:
            VStack(spacing: 8) {
                placeholderIcon("clock")
                Text("Queued...")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
            
        case .running:
            VStack(spacing: 8) {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                Text("Magician at work...")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            
        case .failed:
            VStack(spacing: 8) {
                placeholderIcon("exclamationmark.triangle")
                    .foregroundStyle(AppTheme.Colors.error)
                Text("Failed")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.error)
            }
            
        case .idle:
            placeholderIcon("photo")
        }
    }
    
    private func placeholderIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 24, weight: .light))
            .foregroundStyle(AppTheme.Colors.textTertiary)
    }
}

// MARK: - Button Style

struct AlbumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
    }
}

#Preview {
    AlbumView()
        .environmentObject(AppState())
}
