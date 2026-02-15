//
//  OnboardingStep.swift
//  kivoai
//

import Foundation

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome = 0
    case interests = 1
    case howItWorks = 2
    case rating = 3

    var id: Int { rawValue }

    var isLast: Bool { self == .rating }

    var buttonLabel: String {
        switch self {
        case .welcome:    return "Get Started"
        case .interests:  return "Continue"
        case .howItWorks: return "Continue"
        case .rating:     return "Done"
        }
    }
}
