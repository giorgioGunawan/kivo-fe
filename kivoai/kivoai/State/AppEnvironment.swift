//
//  AppEnvironment.swift
//  kivoai
//

import Foundation
import Combine

final class AppEnvironment: ObservableObject {
    let imageService: ImageGenerationService
    
    init(imageService: ImageGenerationService = MockImageGenerationService()) {
        self.imageService = imageService
    }
}
