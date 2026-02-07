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

class MockAuthBackend: AuthBackend {
    func exchangeAppleToken(identityToken: String, userIdentifier: String) async throws -> AuthResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Return fake JWT
        return AuthResponse(
            accessToken: "mock.jwt.token",
            userIdentifier: userIdentifier
        )
    }
}
