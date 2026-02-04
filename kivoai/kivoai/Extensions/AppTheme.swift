//
//  AppTheme.swift
//  kivoai
//
//  Semantic design tokens for consistency and composability.
//

import SwiftUI

// MARK: - Design Tokens

enum AppTheme {
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 999
    }
    
    // MARK: - Typography
    
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 11, weight: .regular)
    }
    
    // MARK: - Semantic Colors
    
    enum Colors {
        // Brand
        static let accent = Color.kivoAccent
        static let accentSecondary = Color.kivoPink
        
        // Surfaces - Always light mode
        static let background = Color.white
        static let secondaryBackground = Color(red: 0.97, green: 0.97, blue: 0.98)
        static let tertiaryBackground = Color(red: 0.95, green: 0.95, blue: 0.96)
        static let groupedBackground = Color.white
        
        // Text - Always dark text for light backgrounds
        static let textPrimary = Color(red: 0.05, green: 0.05, blue: 0.1)
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.45)
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.65)
        static let textQuaternary = Color(red: 0.75, green: 0.75, blue: 0.8)
        
        // Semantic
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let credits = Color.orange
        
        // Fills - Always light mode
        static let fill = Color(red: 0.9, green: 0.9, blue: 0.92)
        static let secondaryFill = Color(red: 0.93, green: 0.93, blue: 0.95)
        static let tertiaryFill = Color(red: 0.96, green: 0.96, blue: 0.97)
        
        // Separators
        static let separator = Color(red: 0.85, green: 0.85, blue: 0.87)
        static let opaqueSeparator = Color(red: 0.78, green: 0.78, blue: 0.8)
        static let border = Color.black.opacity(0.08)
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        static let subtle = Color.black.opacity(0.04)
        static let soft = Color.black.opacity(0.08)
        static let medium = Color.black.opacity(0.12)
        static let strong = Color.black.opacity(0.2)
        
        static let premium = Color.black.opacity(0.12)
    }
}

// MARK: - View Extensions

extension View {
    /// Card style with subtle elevation
    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
            .shadow(color: AppTheme.Shadow.soft, radius: 12, x: 0, y: 6)
    }
    
    func templateCardStyle() -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1) // Sharp edge
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8) // Deep shadow
    }
    
    /// Section header style
    func sectionHeader() -> some View {
        self
            .font(AppTheme.Typography.headline)
            .foregroundStyle(AppTheme.Colors.textPrimary)
    }
    
    /// Primary button style
    func primaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
    
    /// Secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.headline)
            .foregroundStyle(AppTheme.Colors.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.secondaryFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}

// MARK: - Gradients

extension LinearGradient {
    static let accentGradient = LinearGradient(
        colors: [AppTheme.Colors.accent, AppTheme.Colors.accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
