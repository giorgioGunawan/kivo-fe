//
//  MockImageGenerationService.swift
//  kivoai
//

import Foundation
import UIKit

final class MockImageGenerationService: ImageGenerationService {
    
    private let failureRate: Double = 0.1 // 10% chance of failure
    
    func generateImage(_ request: GenerateImageRequest) async throws -> GenerateImageResult {
        // Simulate network delay (1-2 seconds)
        let delay = Double.random(in: 1.0...2.0)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Simulate occasional failure
        if Double.random(in: 0...1) < failureRate {
            throw ImageGenerationError.processingFailed
        }
        
        // Generate a placeholder image
        let image = createPlaceholderImage(for: request)
        
        // Save to temporary directory
        let jobId = UUID()
        let fileURL = try saveImage(image, jobId: jobId)
        
        return GenerateImageResult(jobId: jobId, backendJobId: Int.random(in: 1...10000), localImageURL: fileURL)
    }
    
    func createJob(_ request: GenerateImageRequest) async throws -> Int {
        // Simulate network delay
        let delay = Double.random(in: 0.3...0.8)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Simulate occasional failure
        if Double.random(in: 0...1) < failureRate {
            throw ImageGenerationError.processingFailed
        }
        
        // Return a mock backend job ID
        return Int.random(in: 1...10000)
    }
    
    func checkJobStatus(backendJobId: Int) async throws -> GenerateImageResult {
        // Simulate checking job status
        let delay = Double.random(in: 0.5...1.5)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Simulate occasional failure
        if Double.random(in: 0...1) < failureRate {
            throw ImageGenerationError.processingFailed
        }
        
        // Generate a mock completed result
        let image = createPlaceholderImage(for: GenerateImageRequest(
            prompt: "Resumed job",
            templateId: nil,
            inputImageURL: nil,
            estimatedCreditCost: 10
        ))
        
        let jobId = UUID()
        let fileURL = try saveImage(image, jobId: jobId)
        
        return GenerateImageResult(jobId: jobId, backendJobId: backendJobId, localImageURL: fileURL)
    }
    
    private func createPlaceholderImage(for request: GenerateImageRequest) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw gradient background
            let colors = randomGradientColors()
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [colors.0.cgColor, colors.1.cgColor] as CFArray,
                locations: [0, 1]
            )!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Draw "AI Generated" text
            let titleText = "✨ AI Generated ✨"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleSize = titleText.size(withAttributes: titleAttributes)
            let titlePoint = CGPoint(
                x: (size.width - titleSize.width) / 2,
                y: size.height / 2 - 60
            )
            titleText.draw(at: titlePoint, withAttributes: titleAttributes)
            
            // Draw prompt preview
            let promptPreview = String(request.prompt.prefix(50)) + (request.prompt.count > 50 ? "..." : "")
            let promptAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            let promptRect = CGRect(
                x: 20,
                y: size.height / 2,
                width: size.width - 40,
                height: 80
            )
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            var attrs = promptAttributes
            attrs[.paragraphStyle] = paragraphStyle
            promptPreview.draw(in: promptRect, withAttributes: attrs)
            
            // Draw decorative elements
            let circleSize: CGFloat = 60
            UIColor.white.withAlphaComponent(0.2).setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 30, y: 30, width: circleSize, height: circleSize))
            context.cgContext.fillEllipse(in: CGRect(x: size.width - circleSize - 30, y: size.height - circleSize - 30, width: circleSize, height: circleSize))
        }
    }
    
    private func randomGradientColors() -> (UIColor, UIColor) {
        let palettes: [(UIColor, UIColor)] = [
            (UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1), UIColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1)),
            (UIColor(red: 0.1, green: 0.6, blue: 0.9, alpha: 1), UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1)),
            (UIColor(red: 0.9, green: 0.4, blue: 0.3, alpha: 1), UIColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1)),
            (UIColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 1), UIColor(red: 0.1, green: 0.5, blue: 0.7, alpha: 1)),
            (UIColor(red: 0.6, green: 0.2, blue: 0.5, alpha: 1), UIColor(red: 0.2, green: 0.2, blue: 0.6, alpha: 1))
        ]
        return palettes.randomElement()!
    }
    
    private func saveImage(_ image: UIImage, jobId: UUID) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
        let filename = "kivo_\(jobId.uuidString).jpg"
        let fileURL = directory.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw ImageGenerationError.processingFailed
        }
        
        try data.write(to: fileURL)
        return fileURL
    }
}
