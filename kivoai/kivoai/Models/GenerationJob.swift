//
//  GenerationJob.swift
//  kivoai
//

import Foundation

struct FileUtils {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func getURL(for relativePath: String) -> URL {
        return documentsDirectory.appendingPathComponent(relativePath)
    }
}

enum GenerationStatus: Equatable, Codable, Hashable {
    case idle
    case queued
    case running(progress: Double?)
    case completed(relativePath: String)
    case failed(message: String)
    
    var isInProgress: Bool {
        switch self {
        case .queued, .running: return true
        default: return false
        }
    }
    
    var localURL: URL? {
        if case .completed(let path) = self {
            return FileUtils.getURL(for: path)
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case type, progress, relativePath, message
    }
    
    private enum TypeKey: String, Codable {
        case idle, queued, running, completed, failed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TypeKey.self, forKey: .type)
        switch type {
        case .idle: self = .idle
        case .queued: self = .queued
        case .running:
            let progress = try container.decodeIfPresent(Double.self, forKey: .progress)
            self = .running(progress: progress)
        case .completed:
            // Check for relativePath first
            if let path = try? container.decode(String.self, forKey: .relativePath) {
                self = .completed(relativePath: path)
            } else {
                // Fallback for old data?
                // Old data had "localURL"
                self = .failed(message: "Image no longer available")
            }
        case .failed:
            let message = try container.decode(String.self, forKey: .message)
            self = .failed(message: message)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .idle:
            try container.encode(TypeKey.idle, forKey: .type)
        case .queued:
            try container.encode(TypeKey.queued, forKey: .type)
        case .running(let progress):
            try container.encode(TypeKey.running, forKey: .type)
            try container.encodeIfPresent(progress, forKey: .progress)
        case .completed(let path):
            try container.encode(TypeKey.completed, forKey: .type)
            try container.encode(path, forKey: .relativePath)
        case .failed(let message):
            try container.encode(TypeKey.failed, forKey: .type)
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
    private let inputImageRelativePath: String?
    
    var isCustom: Bool { templateId == nil }
    
    var inputImageURL: URL? {
        guard let path = inputImageRelativePath else { return nil }
        return FileUtils.getURL(for: path)
    }
    
    var outputImageURL: URL? {
        status.localURL
    }
    
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
        
        if let url = inputImageURL {
            // Check if it's already a relative path in Documents
            let urlString = url.path
            if urlString.contains("/Creations/") {
                 // Extract path after /Documents/
                 if let range = urlString.range(of: "/Documents/") {
                     let relative = String(urlString[range.upperBound...])
                     self.inputImageRelativePath = relative
                 } else {
                     // Assume the filename is unique enough if we can't find Documents root?
                     // Or force it to stay relative
                     self.inputImageRelativePath = "Creations/" + url.lastPathComponent
                 }
            } else {
                self.inputImageRelativePath = nil
            }
        } else {
            self.inputImageRelativePath = nil
        }
    }
    
    // Custom coding keys to rename inputImageRelativePath -> inputImageURL for JSON compatibility?
    // No, new field name is fine as old data is broken.
}
