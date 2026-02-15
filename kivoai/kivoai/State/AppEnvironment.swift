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
    let storeKitManager: StoreKitManager

    private var cancellables = Set<AnyCancellable>()

    init() {
        let auth = AuthManager(backend: RealAuthBackend())
        self.authManager = auth
        let client = APIClient(authManager: auth)
        self.apiClient = client
        self.imageService = KivoImageGenerationService(apiClient: client)
        let storeKitManager = StoreKitManager()
        self.storeKitManager = storeKitManager
        
        // Forward StoreKitManager updates to trigger UI refreshes
        storeKitManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
