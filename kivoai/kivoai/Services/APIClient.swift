//
//  APIClient.swift
//  kivoai
//

import Foundation

class APIClient {
    private let authManager: AuthManager
    private let baseURL = URL(string: "https://api.kivo.ai")! // Placeholder
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func performRequest<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        // Attach Authorization header
        if let token = await authManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // In this phase, we are just preparing the client.
        // real network calls would happen here.
        // For now, let's just log and throw an error or return mock data if needed.
        print("Performing \(method) request to \(url)")
        if let authHeader = request.allHTTPHeaderFields?["Authorization"] {
            print("Auth Header: \(authHeader)")
        }
        
        // Simulating that we don't have a real backend yet
        throw APIError.notImplemented
    }
}

enum APIError: Error {
    case notImplemented
    case unauthorized
}
