//
//  GenerationJob.swift
//  kivoai
//

import Foundation

enum GenerationStatus: Equatable, Codable, Hashable {
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
    
    enum CodingKeys: String, CodingKey {
        case type, progress, localURL, message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "idle": self = .idle
        case "queued": self = .queued
        case "running":
            let progress = try container.decodeIfPresent(Double.self, forKey: .progress)
            self = .running(progress: progress)
        case "completed":
            let url = try container.decode(URL.self, forKey: .localURL)
            self = .completed(localURL: url)
        case "failed":
            let message = try container.decode(String.self, forKey: .message)
            self = .failed(message: message)
        default:
            self = .idle
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .idle:
            try container.encode("idle", forKey: .type)
        case .queued:
            try container.encode("queued", forKey: .type)
        case .running(let progress):
            try container.encode("running", forKey: .type)
            try container.encodeIfPresent(progress, forKey: .progress)
        case .completed(let url):
            try container.encode("completed", forKey: .type)
            try container.encode(url, forKey: .localURL)
        case .failed(let message):
            try container.encode("failed", forKey: .type)
            try container.encode(message, forKey: .message)
        }
    }
}

struct GenerationJob: Identifiable, Codable, Hashable {
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
