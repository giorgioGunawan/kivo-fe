//
//  TemplateCategory.swift
//  kivoai
//

import Foundation

enum TemplateCategory: String, CaseIterable, Identifiable {
    case pranks
    case appearance
    case fantasy
    case popCulture
    case stylization
    case transformation
    case surveillance
    case status
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .pranks: return "Pranks"
        case .appearance: return "Appearance"
        case .fantasy: return "Fantasy"
        case .popCulture: return "Pop Culture"
        case .stylization: return "Stylization"
        case .transformation: return "Transformation"
        case .surveillance: return "Surveillance"
        case .status: return "Status"
        }
    }
    
    var iconName: String {
        switch self {
        case .pranks: return "face.smiling"
        case .appearance: return "person.fill.viewfinder"
        case .fantasy: return "sparkles"
        case .popCulture: return "gamecontroller.fill"
        case .stylization: return "paintbrush.pointed.fill"
        case .transformation: return "figure.walk"
        case .surveillance: return "video.fill"
        case .status: return "star.fill"
        }
    }
}
