//
//  TemplateCategory.swift
//  kivoai
//

import Foundation

enum TemplateCategory: String, CaseIterable, Identifiable {
    case pranks
    case hair
    case tattoos
    case cartoon
    case faceTransformations
    case people

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pranks: return "Pranks"
        case .hair: return "Hair"
        case .tattoos: return "Tattoos"
        case .cartoon: return "Cartoon"
        case .faceTransformations: return "Face Transformations"
        case .people: return "People"
        }
    }

    var iconName: String {
        switch self {
        case .pranks: return "face.smiling"
        case .hair: return "scissors"
        case .tattoos: return "paintbrush.fill"
        case .cartoon: return "paintpalette.fill"
        case .faceTransformations: return "wand.and.stars"
        case .people: return "person.2.fill"
        }
    }
}
