//
//  Color+Extensions.swift
//  kivoai
//

import SwiftUI

extension Color {
    // Primary brand colors
    static let kivoAccent = Color(red: 0.4, green: 0.3, blue: 0.9)
    static let kivoPink = Color(red: 0.9, green: 0.3, blue: 0.6)
    static let kivoGradientStart = Color(red: 0.25, green: 0.15, blue: 0.35)
    static let kivoGradientEnd = Color(red: 0.1, green: 0.08, blue: 0.15)
    
    // Background colors
    static let kivoBackground = Color(red: 0.08, green: 0.06, blue: 0.12)
    static let kivoCardBackground = Color(red: 0.12, green: 0.1, blue: 0.18)
    static let kivoCardBackgroundLight = Color(red: 0.16, green: 0.14, blue: 0.22)
    
    // Text colors
    static let kivoTextPrimary = Color.white
    static let kivoTextSecondary = Color.white.opacity(0.7)
    static let kivoTextTertiary = Color.white.opacity(0.5)
    
    // Status colors
    static let kivoSuccess = Color(red: 0.2, green: 0.8, blue: 0.5)
    static let kivoWarning = Color(red: 0.95, green: 0.7, blue: 0.2)
    static let kivoError = Color(red: 0.95, green: 0.3, blue: 0.3)
    
    // Credit indicator
    static let kivoCredits = Color(red: 1.0, green: 0.8, blue: 0.2)
}

extension LinearGradient {
    static let kivoBackground = LinearGradient(
        colors: [Color.kivoGradientStart, Color.kivoGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let kivoAccentGradient = LinearGradient(
        colors: [Color.kivoAccent, Color.kivoPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let kivoButtonGradient = LinearGradient(
        colors: [Color.kivoAccent, Color.kivoAccent.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
}
