//
//  ImageGenerationService.swift
//  kivoai
//

import Foundation

struct GenerateImageRequest {
    let prompt: String
    let templateId: String?
    let inputImageURL: URL?
    let estimatedCreditCost: Int
}

struct GenerateImageResult {
    let jobId: UUID
    let localImageURL: URL
}

enum ImageGenerationError: Error, LocalizedError {
    case networkError
    case processingFailed
    case invalidInput
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError: return "Network connection failed"
        case .processingFailed: return "Image processing failed"
        case .invalidInput: return "Invalid input provided"
        case .serverError(let msg): return msg
        }
    }
}

protocol ImageGenerationService {
    func generateImage(_ request: GenerateImageRequest) async throws -> GenerateImageResult
}
