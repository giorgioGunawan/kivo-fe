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
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Image
                    imageSection
                    
                    // Info
                    infoSection
                    
                    // Actions
                    actionButtons
                    
                    Spacer()
                        .frame(height: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, 60) // Space for floating back button
            }
            
            // Floating Back Button
            backButton
        }
        .navigationBarHidden(true)
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
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
    
    // MARK: - Image
    
    private var imageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                .fill(AppTheme.Colors.secondaryBackground)
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: AppTheme.Shadow.soft, radius: 10, x: 0, y: 4)
            
            if case .completed(let localURL) = job.status,
               let data = try? Data(contentsOf: localURL),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous))
            } else {
                VStack(spacing: AppTheme.Spacing.md) {
                    ProgressView()
                    Text("Loading generation...")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
        }
    }
    
    // MARK: - Info
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text(job.isCustom ? "Custom" : job.templateTitle)
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text(job.createdAt, style: .date)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }
            
            if !job.prompt.isEmpty {
                Text(job.prompt)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(AppTheme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            }
        }
    }
    
    // MARK: - Actions
    
    private var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button(action: saveImage) {
                Label("Save to Photos", systemImage: "square.and.arrow.down")
                    .primaryButtonStyle()
            }
            .buttonStyle(.plain)
            
            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: shareImage) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .secondaryButtonStyle()
                }
                .buttonStyle(.plain)
                
                Button(action: deleteImage) {
                    Label("Delete", systemImage: "trash")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.error)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.Colors.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Action Methods
    
    private func saveImage() {
        if case .completed(let url) = job.status,
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    private func shareImage() {
        if case .completed(let url) = job.status {
            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(av, animated: true, completion: nil)
            }
        }
    }
    
    private func deleteImage() {
        dismiss()
    }
}
