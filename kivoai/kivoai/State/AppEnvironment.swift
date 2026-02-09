//
//  AppEnvironment.swift
//  kivoai
//

import Foundation
import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    let imageService: ImageGenerationService
    let authManager: AuthManager
    let apiClient: APIClient
    
    init() {
        let auth = AuthManager(backend: RealAuthBackend())
        self.authManager = auth
        let client = APIClient(authManager: auth)
        self.apiClient = client
        self.imageService = KivoImageGenerationService(apiClient: client)
    }
}
