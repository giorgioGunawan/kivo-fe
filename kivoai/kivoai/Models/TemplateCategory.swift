//
//  TemplateCategory.swift
//  kivoai
//

import Foundation

enum TemplateCategory: String, CaseIterable, Identifiable {
    case pranks
    case appearance
    case cartoon
    case faceTransformations
    case people

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pranks: return "Pranks"
        case .appearance: return "Appearance"
        case .cartoon: return "Cartoon"
        case .faceTransformations: return "Face Transformations"
        case .people: return "People"
        }
    }

    var iconName: String {
        switch self {
        case .pranks: return "face.smiling"
        case .appearance: return "sparkles"
        case .cartoon: return "paintpalette.fill"
        case .faceTransformations: return "wand.and.stars"
        case .people: return "person.2.fill"
        }
    }
}
