//
//  Color+Extensions.swift
//  kivoai
//

import SwiftUI

extension Color {
    // Primary brand colors
    static let kivoAccent = Color(red: 0.48, green: 0.38, blue: 1.0) // Deep Purple
    static let kivoPink = Color(red: 0.65, green: 0.45, blue: 1.0) // Lighter Purple/Violet
    
    // Background colors
    static let kivoBackground = Color(red: 0.97, green: 0.98, blue: 1.0) // Off-white/Cool gray
    static let kivoCardBackground = Color.white
    static let kivoCardBackgroundLight = Color(white: 0.95)
    
    // Text colors
    static let kivoTextPrimary = Color(red: 0.05, green: 0.05, blue: 0.1) // Near black
    static let kivoTextSecondary = Color(red: 0.3, green: 0.3, blue: 0.4) // Slate gray
    static let kivoTextTertiary = Color(red: 0.5, green: 0.5, blue: 0.6) // Light slate
    
    // Status colors
    static let kivoSuccess = Color(red: 0.15, green: 0.7, blue: 0.4)
    static let kivoWarning = Color(red: 0.9, green: 0.6, blue: 0.1)
    static let kivoError = Color(red: 0.9, green: 0.2, blue: 0.2)
    
    // Credit indicator
    static let kivoCredits = Color(red: 1.0, green: 0.6, blue: 0.0) // Amber
}

extension LinearGradient {
    static let kivoBackground = LinearGradient(
        colors: [Color.kivoBackground, Color.kivoBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let kivoAccentGradient = LinearGradient(
        colors: [Color.kivoAccent, Color.kivoPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let kivoButtonGradient = LinearGradient(
        colors: [Color.kivoAccent, Color.kivoAccent.opacity(0.85)],
        startPoint: .top,
        endPoint: .bottom
    )
}
