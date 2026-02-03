//
//  TemplateCardView.swift
//  kivoai
//

import SwiftUI

struct TemplateCardView: View {
    let template: Template
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder area
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: gradientColors(for: template.category),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Icon overlay
                Image(systemName: template.category.iconName)
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
                
                // Decorative elements
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .offset(x: 40, y: -30)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 50, height: 50)
                    .offset(x: -35, y: 35)
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(template.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.kivoTextPrimary)
                    .lineLimit(1)
                
                Text(template.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .top)
            }
        }
        .padding(12)
        .background(Color.kivoCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
    }
    
    private func gradientColors(for category: TemplateCategory) -> [Color] {
        switch category {
        case .pranks:
            return [Color(red: 0.9, green: 0.3, blue: 0.4), Color(red: 0.7, green: 0.2, blue: 0.5)]
        case .fashion:
            return [Color(red: 0.8, green: 0.5, blue: 0.9), Color(red: 0.5, green: 0.3, blue: 0.8)]
        case .relationships:
            return [Color(red: 0.9, green: 0.4, blue: 0.5), Color(red: 0.8, green: 0.3, blue: 0.6)]
        case .lifestyle:
            return [Color(red: 0.3, green: 0.6, blue: 0.9), Color(red: 0.4, green: 0.4, blue: 0.8)]
        case .other:
            return [Color(red: 0.4, green: 0.7, blue: 0.6), Color(red: 0.3, green: 0.5, blue: 0.7)]
        }
    }
}

#Preview {
    ZStack {
        Color.kivoBackground.ignoresSafeArea()
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            TemplateCardView(template: Template.sampleTemplates[0])
            TemplateCardView(template: Template.sampleTemplates[3])
        }
        .padding()
    }
}
