//
//  AuthManager.swift
//  kivoai
//

import Foundation
import SwiftUI
import AuthenticationServices
import Combine

@MainActor
class AuthManager: NSObject, ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isAuthenticating: Bool = false
    
    private let backend: AuthBackend
    private let keychain = KeychainHelper.shared
    private let serviceName = "com.kivo.auth"
    private let tokenAccount = "accessToken"
    private let userAccount = "userIdentifier"
    
    init(backend: AuthBackend = MockAuthBackend()) {
        self.backend = backend
        super.init()
        self.isAuthenticated = getAccessToken() != nil
    }
    
    nonisolated func getAccessToken() -> String? {
        guard let data = KeychainHelper.shared.read(service: "com.kivo.auth", account: "accessToken") else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    nonisolated func getUserIdentifier() -> String? {
        guard let data = KeychainHelper.shared.read(service: "com.kivo.auth", account: "userIdentifier") else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func signInWithApple() async throws {
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // We need to bridge the delegate-based ASAuthorizationController to async/await
        return try await withCheckedThrowingContinuation { continuation in
            self.signInContinuation = continuation
            controller.performRequests()
        }
    }
    
    func completeSignInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }
        
        let userIdentifier = appleIDCredential.user
        await handleSuccessfulSignIn(identityToken: identityToken, userIdentifier: userIdentifier)
    }
    
    private var signInContinuation: CheckedContinuation<Void, Error>?
    
    func signOut() {
        keychain.delete(service: serviceName, account: tokenAccount)
        keychain.delete(service: serviceName, account: userAccount)
        isAuthenticated = false
    }
    
    private func handleSuccessfulSignIn(identityToken: String, userIdentifier: String) async {
        do {
            let response = try await backend.exchangeAppleToken(identityToken: identityToken, userIdentifier: userIdentifier)
            
            if let tokenData = response.accessToken.data(using: .utf8) {
                keychain.save(tokenData, service: serviceName, account: tokenAccount)
            }
            
            if let userData = response.userIdentifier.data(using: .utf8) {
                keychain.save(userData, service: serviceName, account: userAccount)
            }
            
            isAuthenticated = true
            signInContinuation?.resume()
        } catch {
            signInContinuation?.resume(throwing: error)
        }
        signInContinuation = nil
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            signInContinuation?.resume(throwing: AuthError.invalidCredential)
            signInContinuation = nil
            return
        }
        
        let userIdentifier = appleIDCredential.user
        
        Task {
            await handleSuccessfulSignIn(identityToken: identityToken, userIdentifier: userIdentifier)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        signInContinuation?.resume(throwing: error)
        signInContinuation = nil
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

enum AuthError: Error {
    case invalidCredential
}
