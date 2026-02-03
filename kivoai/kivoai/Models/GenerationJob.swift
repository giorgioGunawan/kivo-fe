//
//  GenerationJob.swift
//  kivoai
//

import Foundation

enum GenerationStatus: Equatable {
    case idle
    case queued
    case running(progress: Double?)
    case completed(localURL: URL)
    case failed(message: String)
    
    var isInProgress: Bool {
        switch self {
        case .queued, .running: return true
        default: return false
        }
    }
}

struct GenerationJob: Identifiable {
    let id: UUID
    let templateId: String? // nil for custom generations
    let templateTitle: String
    let createdAt: Date
    var status: GenerationStatus
    let creditCost: Int
    let prompt: String
    let inputImageURL: URL?
    
    var isCustom: Bool { templateId == nil }
    
    init(
        id: UUID = UUID(),
        templateId: String?,
        templateTitle: String,
        createdAt: Date = Date(),
        status: GenerationStatus = .queued,
        creditCost: Int,
        prompt: String,
        inputImageURL: URL? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.templateTitle = templateTitle
        self.createdAt = createdAt
        self.status = status
        self.creditCost = creditCost
        self.prompt = prompt
        self.inputImageURL = inputImageURL
    }
}
