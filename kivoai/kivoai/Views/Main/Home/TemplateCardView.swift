//
//  TemplateCardView.swift
//  kivoai
//
//  Full-image template card with before/after transition.
//

import SwiftUI
import Combine

private enum CardWipeTimer {
    static let shared = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
}

struct TemplateCardView: View {
    let template: Template
    @State private var wipeProgress: CGFloat = 0

    private let cardWidth: CGFloat = 155
    private let cardHeight: CGFloat = 210

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background images with wipe-line transition
            ZStack {
                if !template.beforeImageName.isEmpty,
                   let beforeImg = UIImage(named: template.beforeImageName) {
                    Image(uiImage: beforeImg)
                        .resizable()
                        .scaledToFill()
                }

                if !template.afterImageName.isEmpty,
                   let afterImg = UIImage(named: template.afterImageName) {
                    Image(uiImage: afterImg)
                        .resizable()
                        .scaledToFill()
                        .clipShape(
                            WipeShape(progress: wipeProgress)
                        )

                    // Wipe line
                    if wipeProgress > 0 && wipeProgress < 1 {
                        Rectangle()
                            .fill(.white.opacity(0.8))
                            .frame(height: 2)
                            .offset(y: -cardHeight / 2 + wipeProgress * cardHeight)
                    }
                }

                // Fallback gradient if no images
                if template.beforeImageName.isEmpty && template.afterImageName.isEmpty {
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
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipped()

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
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
        .onReceive(CardWipeTimer.shared) { _ in
            guard !template.beforeImageName.isEmpty, !template.afterImageName.isEmpty else { return }
            withAnimation(.easeInOut(duration: 1.0)) {
                wipeProgress = wipeProgress == 0 ? 1 : 0
            }
        }
    }

    private func gradientColors(for category: TemplateCategory) -> [Color] {
        switch category {
        case .pranks:
            return [Color(red: 0.95, green: 0.4, blue: 0.5), Color(red: 0.85, green: 0.3, blue: 0.6)]
        case .appearance:
            return [Color(red: 0.4, green: 0.55, blue: 0.95), Color(red: 0.3, green: 0.35, blue: 0.85)]
        case .cartoon:
            return [Color(red: 0.7, green: 0.45, blue: 0.95), Color(red: 0.55, green: 0.3, blue: 0.85)]
        case .faceTransformations:
            return [Color(red: 0.25, green: 0.75, blue: 0.75), Color(red: 0.15, green: 0.55, blue: 0.65)]
        case .people:
            return [Color(red: 0.95, green: 0.55, blue: 0.35), Color(red: 0.85, green: 0.35, blue: 0.25)]
        }
    }
}

private struct WipeShape: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: 0, y: 0, width: rect.width, height: rect.height * progress))
        return path
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()

        HStack(spacing: 16) {
            TemplateCardView(template: Template.sampleTemplates[0])
            TemplateCardView(template: Template.sampleTemplates[7])
        }
        .padding()
    }
}
