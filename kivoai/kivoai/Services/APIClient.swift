//
//  APIClient.swift
//  kivoai
//

import Foundation

class APIClient {
    private let authManager: AuthManager
    let baseURL = URL(string: "https://kivo-be-production.up.railway.app")!
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func performRequest<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil, contentType: String = "application/json") async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        // Attach Authorization header
        if let token = await authManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add Idempotency-Key for POST requests
        if method == "POST" {
            request.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
        }
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 402 {
            throw APIError.insufficientCredits
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Server error (\(httpResponse.statusCode)): \(serverMessage)")
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    func uploadImage(data: Data, filename: String) async throws -> String {
        let url = baseURL.appendingPathComponent("jobs/upload")
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
        
        if let token = await authManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (responseData, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: responseData, encoding: .utf8) ?? "Unknown upload error"
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Upload failed: \(serverMessage)")
        }
        
        let uploadResponse = try decoder.decode(UploadResponse.self, from: responseData)
        return uploadResponse.url
    }
    
    func fetchBalance() async throws -> CreditBalance {
        return try await performRequest(endpoint: "credits/balance")
    }
    
    func verifySubscription(transactionId: String) async throws {
        let body = ["originalTransactionId": transactionId]
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        let _: EmptyResponse = try await performRequest(endpoint: "auth/subscription/verify", method: "POST", body: jsonData)
    }
}

struct EmptyResponse: Decodable {}

struct UploadResponse: Decodable {
    let url: String
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case insufficientCredits
    case serverError(statusCode: Int, message: String)
    case uploadFailed
    case notImplemented
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .insufficientCredits: return "Insufficient credits. Please upgrade to Pro."
        case .serverError(_, let message): return message
        case .uploadFailed: return "Image upload failed"
        default: return "A network error occurred"
        }
    }
}
