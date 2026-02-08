//
//  TemplateCardView.swift
//  kivoai
//
//  Full-image template card inspired by elite UI styles.
//

import SwiftUI

struct TemplateCardView: View {
    let template: Template
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image/Gradient
            ZStack {
                // Background color to ensure no transparency issues
                Color.white
                
                LinearGradient(
                    colors: gradientColors(for: template.category),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Image(systemName: template.category.iconName)
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .overlay(
                // Elegant inner border for definition
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            
            // Bottom shadow overlay for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 90)
            
            // Text Content
            VStack(alignment: .leading, spacing: 0) {
                Text(template.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppTheme.Spacing.md)
        }
        .aspectRatio(0.75, contentMode: .fill) // Ensure it fills the frame
        .templateCardStyle()
    }
    
    private func gradientColors(for category: TemplateCategory) -> [Color] {
        switch category {
        case .pranks:
            return [Color(red: 0.95, green: 0.4, blue: 0.5), Color(red: 0.85, green: 0.3, blue: 0.6)]
        case .appearance:
            return [Color(red: 0.7, green: 0.5, blue: 0.95), Color(red: 0.55, green: 0.4, blue: 0.9)]
        case .fantasy:
            return [Color(red: 0.95, green: 0.55, blue: 0.8), Color(red: 0.8, green: 0.4, blue: 0.9)]
        case .popCulture:
            return [Color(red: 0.4, green: 0.85, blue: 0.6), Color(red: 0.3, green: 0.65, blue: 0.5)]
        case .stylization:
            return [Color(red: 0.95, green: 0.7, blue: 0.4), Color(red: 0.9, green: 0.5, blue: 0.3)]
        case .transformation:
            return [Color(red: 0.3, green: 0.5, blue: 0.8), Color(red: 0.2, green: 0.3, blue: 0.7)]
        case .surveillance:
            return [Color(red: 0.5, green: 0.55, blue: 0.6), Color(red: 0.3, green: 0.35, blue: 0.4)]
        case .status:
            return [Color(red: 0.95, green: 0.8, blue: 0.4), Color(red: 0.8, green: 0.6, blue: 0.2)]
        }
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        
        HStack(spacing: 16) {
            TemplateCardView(template: Template.sampleTemplates[0])
                .frame(width: 170)
            TemplateCardView(template: Template.sampleTemplates[2])
                .frame(width: 170)
        }
        .padding()
    }
}
