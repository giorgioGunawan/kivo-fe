//
//  AppEnvironment.swift
//  kivoai
//

import Foundation
import Combine

final class AppEnvironment: ObservableObject {
    let imageService: ImageGenerationService
    let authManager: AuthManager
    let apiClient: APIClient
    
    init(imageService: ImageGenerationService = MockImageGenerationService()) {
        self.imageService = imageService
        let auth = AuthManager()
        self.authManager = auth
        self.apiClient = APIClient(authManager: auth)
    }
}
