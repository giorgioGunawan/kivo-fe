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

class KivoImageGenerationService: ImageGenerationService {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func generateImage(_ request: GenerateImageRequest) async throws -> GenerateImageResult {
        // Step 1: Upload image if present
        var remoteImageUrl: String? = nil
        if let localURL = request.inputImageURL,
           let data = try? Data(contentsOf: localURL) {
            let filename = localURL.lastPathComponent.contains(".png") ? "input.png" : "input.jpg"
            remoteImageUrl = try await apiClient.uploadImage(data: data, filename: filename)
        }
        
        // Step 2: Create generation job
        let createJobBody: [String: Any] = [
            "media_type": "image",
            "model": "google/nano-banana-edit",
            "prompt": String(request.prompt.prefix(5000)),
            "input_image_url": remoteImageUrl ?? "",
            "output_format": "png"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: createJobBody)
        let createJobResponse: CreateJobResponse = try await apiClient.performRequest(
            endpoint: "jobs",
            method: "POST",
            body: jsonData
        )
        
        let jobId = createJobResponse.jobId
        
        // Step 3: Polling
        var resultUrl: String? = nil
        var attempts = 0
        let maxAttempts = 30 // 30 * 3 seconds = 90 seconds timeout
        
        while attempts < maxAttempts {
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            attempts += 1
            
            let statusResponse: JobStatusResponse = try await apiClient.performRequest(endpoint: "jobs/\(jobId)")
            
            if statusResponse.status == "completed" {
                if let urlString = statusResponse.resultUrl, !urlString.isEmpty {
                    resultUrl = urlString
                    break
                } else {
                    throw ImageGenerationError.processingFailed
                }
            } else if statusResponse.status == "failed" {
                throw ImageGenerationError.processingFailed
            }
            // Otherwise continues polling for "queued" or "processing"
        }
        
        guard let finalUrlString = resultUrl, let finalUrl = URL(string: finalUrlString) else {
            throw ImageGenerationError.networkError
        }
        
        // Step 4: Download result to local storage
        let (imageData, _) = try await URLSession.shared.data(from: finalUrl)
        let localURL = try saveToPersistentFile(data: imageData)
        
        return GenerateImageResult(jobId: UUID(), localImageURL: localURL)
    }
    
    private func saveToPersistentFile(data: Data) throws -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let creationsURL = documentsURL.appendingPathComponent("Creations", isDirectory: true)
        
        if !fileManager.fileExists(atPath: creationsURL.path) {
            try fileManager.createDirectory(at: creationsURL, withIntermediateDirectories: true)
        }
        
        let fileURL = creationsURL.appendingPathComponent(UUID().uuidString + ".jpg")
        try data.write(to: fileURL)
        return fileURL
    }
}

struct CreateJobResponse: Decodable {
    let jobId: Int
    let status: String
}

struct JobStatusResponse: Decodable {
    let jobId: Int?
    let status: String
    let resultUrl: String?
}
