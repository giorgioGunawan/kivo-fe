//
//  AuthBackend.swift
//  kivoai
//

import Foundation

struct AuthResponse {
    let accessToken: String
    let userIdentifier: String
}

protocol AuthBackend {
    func exchangeAppleToken(identityToken: String, userIdentifier: String) async throws -> AuthResponse
}

class RealAuthBackend: AuthBackend {
    private let baseURL = URL(string: "https://kivo-be-production.up.railway.app")!
    
    func exchangeAppleToken(identityToken: String, userIdentifier: String) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("auth/apple")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["identityToken": identityToken]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.invalidCredential
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let backendResponse = try decoder.decode(BackendAuthResponse.self, from: data)
        
        return AuthResponse(
            accessToken: backendResponse.token,
            userIdentifier: userIdentifier
        )
    }
}

class MockAuthBackend: AuthBackend {
    func exchangeAppleToken(identityToken: String, userIdentifier: String) async throws -> AuthResponse {
        return AuthResponse(accessToken: "mock_token", userIdentifier: userIdentifier)
    }
}

struct BackendAuthResponse: Decodable {
    let token: String
}
