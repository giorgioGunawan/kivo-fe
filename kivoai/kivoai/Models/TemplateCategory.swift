//
//  TemplateCategory.swift
//  kivoai
//

import Foundation

enum TemplateCategory: String, CaseIterable, Identifiable {
    case pranks
    case fashion
    case relationships
    case lifestyle
    case other
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .pranks: return "Pranks"
        case .fashion: return "Fashion"
        case .relationships: return "Relationships"
        case .lifestyle: return "Lifestyle"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .pranks: return "face.smiling"
        case .fashion: return "tshirt"
        case .relationships: return "heart.fill"
        case .lifestyle: return "sparkles"
        case .other: return "ellipsis.circle"
        }
    }
}
