//
//  AppState.swift
//  kivoai
//

import Foundation
import SwiftUI
import Combine

enum AppTab {
    case home
    case library
}

@MainActor
final class AppState: ObservableObject {

    // MARK: - Published Properties

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    /// Backend-authoritative. Read from creditBalance.isProSubscriber, persisted as stale
    /// cache. Never set directly — always comes from refreshCreditBalance().
    var isProSubscriber: Bool { creditBalance.isProSubscriber }

    @Published var creditBalance: CreditBalance {
        didSet {
            UserDefaults.standard.set(creditBalance.weeklyRemaining, forKey: Keys.weeklyCredits)
            UserDefaults.standard.set(creditBalance.purchasedRemaining, forKey: Keys.purchasedCredits)
            UserDefaults.standard.set(creditBalance.isProSubscriber, forKey: Keys.isProSubscriber)
        }
    }

    @Published var generationJobs: [GenerationJob] = [] {
        didSet {
            saveJobs()
        }
    }

    @Published var showingPaywall: Bool = false
    @Published var showingCreditsSheet: Bool = false
    @Published var showingExtraCreditsSheet: Bool = false
    @Published var showingCustomCreation: Bool = false
    @Published var activeJobId: UUID? = nil
    @Published var tabBarHidden: Bool = false
    @Published var selectedTab: AppTab = .home
    @Published var debugZeroCredits: Bool = false
    @Published var completionNotification: GenerationJob? = nil
    @Published var preferredCategories: [TemplateCategory] {
        didSet {
            UserDefaults.standard.set(preferredCategories.map { $0.rawValue }, forKey: Keys.preferredCategories)
        }
    }

    // MARK: - Keys

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isProSubscriber = "isProSubscriber"
        static let weeklyCredits = "weeklyCredits"
        static let purchasedCredits = "purchasedCredits"
        static let cachedJobs = "cachedJobs"
        static let preferredCategories = "preferredCategories"
    }

    // MARK: - Init

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)

        let weekly = UserDefaults.standard.integer(forKey: Keys.weeklyCredits)
        let purchased = UserDefaults.standard.integer(forKey: Keys.purchasedCredits)
        // isProSubscriber is a stale cache — will be corrected on next refreshCreditBalance()
        let isProSub = UserDefaults.standard.bool(forKey: Keys.isProSubscriber)
        self.creditBalance = CreditBalance(
            weeklyRemaining: weekly,
            purchasedRemaining: purchased,
            lastWeeklyRefreshAt: nil,
            subscriptionExpiresAt: nil,
            isProSubscriber: isProSub
        )

        if let saved = UserDefaults.standard.stringArray(forKey: Keys.preferredCategories) {
            let ordered = saved.compactMap { TemplateCategory(rawValue: $0) }
            let remaining = TemplateCategory.allCases.filter { !ordered.contains($0) }
            self.preferredCategories = ordered + remaining
        } else {
            self.preferredCategories = TemplateCategory.allCases
        }

        loadJobs()
    }

    // MARK: - Persistence

    private func saveJobs() {
        do {
            let data = try JSONEncoder().encode(generationJobs)
            UserDefaults.standard.set(data, forKey: Keys.cachedJobs)
        } catch {
            print("Failed to save jobs: \(error)")
        }
    }

    private func loadJobs() {
        guard let data = UserDefaults.standard.data(forKey: Keys.cachedJobs) else { return }
        do {
            let jobs = try JSONDecoder().decode([GenerationJob].self, from: data)
            self.generationJobs = jobs
        } catch {
            print("Failed to load jobs: \(error)")
        }
    }

    // MARK: - Credit Methods

    func refreshCreditBalance(apiClient: APIClient) async {
        do {
            let backendBalance = try await apiClient.fetchBalance()
            self.creditBalance = backendBalance
        } catch {
            print("Failed to refresh credit balance: \(error.localizedDescription)")
        }
    }

    func hasEnoughCredits(for cost: Int) -> Bool {
        guard !debugZeroCredits else { return false }
        return creditBalance.total >= cost
    }

    // MARK: - Job Methods

    func addJob(_ job: GenerationJob) {
        generationJobs.insert(job, at: 0)

        // Keep only last 20 (User Request)
        if generationJobs.count > 20 {
            // Remove the oldest job's files if it exists
            let oldestJob = generationJobs.last
            cleanupJobFiles(oldestJob)
            generationJobs.removeLast()
        }
    }

    func updateJobStatus(jobId: UUID, status: GenerationStatus) {
        if let index = generationJobs.firstIndex(where: { $0.id == jobId }) {
            generationJobs[index].status = status
            if case .completed = status {
                completionNotification = generationJobs[index]
            }
            saveJobs()
        }
    }
    
    func updateJobBackendId(jobId: UUID, backendJobId: Int) {
        if let index = generationJobs.firstIndex(where: { $0.id == jobId }) {
            generationJobs[index].backendJobId = backendJobId
            saveJobs()
        }
    }

    func deleteJob(_ job: GenerationJob) {
        cleanupJobFiles(job)
        generationJobs.removeAll(where: { $0.id == job.id })
    }

    private func cleanupJobFiles(_ job: GenerationJob?) {
        guard let job = job else { return }

        // Delete input image
        if let inputURL = job.inputImageURL {
            try? FileManager.default.removeItem(at: inputURL)
        }

        // Delete output image if completed
        if let outputURL = job.outputImageURL {
            try? FileManager.default.removeItem(at: outputURL)
        }
    }

    func checkAndResumeJobs(apiClient: APIClient, imageService: ImageGenerationService) {
        for job in generationJobs {
            if job.status.isInProgress {
                Task {
                    await resumeJob(job, apiClient: apiClient, imageService: imageService)
                }
            }
        }
    }

    private func resumeJob(_ job: GenerationJob, apiClient: APIClient, imageService: ImageGenerationService) async {
        // Only resume jobs that have a backend job ID
        // Jobs without a backend ID are still in their original generation task
        guard let backendJobId = job.backendJobId else {
            print("[AppState] Skipping resume for job \(job.id) - no backend job ID yet (original task still running)")
            return
        }
        
        do {
            let result = try await imageService.checkJobStatus(backendJobId: backendJobId)
            let relativePath = "Creations/" + result.localImageURL.lastPathComponent
            updateJobStatus(jobId: job.id, status: .completed(relativePath: relativePath))
            await refreshCreditBalance(apiClient: apiClient)
        } catch {
            updateJobStatus(jobId: job.id, status: .failed(message: error.localizedDescription))
            await refreshCreditBalance(apiClient: apiClient)
        }
    }

    func hasJobInProgress() -> Bool {
        generationJobs.contains { $0.status.isInProgress }
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    // MARK: - Subscription Flow

    func handleSubscriptionVerification(transactionId: String, productId: String? = nil, apiClient: APIClient) async throws {
        try await apiClient.verifySubscription(transactionId: transactionId, productId: productId)
        // isProSubscriber is derived from the refreshed balance — never set directly
        await refreshCreditBalance(apiClient: apiClient)
    }

    // MARK: - Reset (for testing)

    func resetAll() {
        hasCompletedOnboarding = false
        creditBalance = .zero
        generationJobs = []
    }
}
