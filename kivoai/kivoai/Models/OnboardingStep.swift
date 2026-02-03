//
//  OnboardingStep.swift
//  kivoai
//

import Foundation

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case value = 0
    case templates = 1
    case control = 2
    case callToAction = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .value: return "AI Magic"
        case .templates: return "Guided Templates"
        case .control: return "You're in Control"
        case .callToAction: return "Ready?"
        }
    }
    
    var subtitle: String {
        switch self {
        case .value: return "Turn photos into viral AI pranks"
        case .templates: return "Guided templates — just point and tap"
        case .control: return "Weekly credits, optional top-ups"
        case .callToAction: return "Let's create something amazing"
        }
    }
    
    var iconName: String {
        switch self {
        case .value: return "wand.and.stars"
        case .templates: return "square.grid.2x2"
        case .control: return "bolt.shield"
        case .callToAction: return "rocket.fill"
        }
    }
    
    var isLast: Bool {
        self == .callToAction
    }
}
