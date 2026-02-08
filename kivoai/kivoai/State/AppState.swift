//
//  AppState.swift
//  kivoai
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }
    
    @Published var isProSubscriber: Bool {
        didSet {
            UserDefaults.standard.set(isProSubscriber, forKey: Keys.isProSubscriber)
        }
    }
    
    @Published var creditBalance: CreditBalance {
        didSet {
            UserDefaults.standard.set(creditBalance.weeklyRemaining, forKey: Keys.weeklyCredits)
            UserDefaults.standard.set(creditBalance.purchasedRemaining, forKey: Keys.purchasedCredits)
            UserDefaults.standard.set(creditBalance.weeklyResetAt, forKey: Keys.weeklyResetAt)
        }
    }
    
    @Published var generationJobs: [GenerationJob] = [] {
        didSet {
            saveJobs()
        }
    }
    
    @Published var showingPaywall: Bool = false
    @Published var showingCreditsSheet: Bool = false
    @Published var showingCustomCreation: Bool = false
    @Published var activeJobId: UUID? = nil
    @Published var tabBarHidden: Bool = false
    
    // MARK: - Keys
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isProSubscriber = "isProSubscriber"
        static let weeklyCredits = "weeklyCredits"
        static let purchasedCredits = "purchasedCredits"
        static let weeklyResetAt = "weeklyResetAt"
        static let cachedJobs = "cachedJobs"
    }
    
    // MARK: - Init
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        self.isProSubscriber = UserDefaults.standard.bool(forKey: Keys.isProSubscriber)
        
        let weekly = UserDefaults.standard.integer(forKey: Keys.weeklyCredits)
        let purchased = UserDefaults.standard.integer(forKey: Keys.purchasedCredits)
        let resetAt = UserDefaults.standard.string(forKey: Keys.weeklyResetAt)
        self.creditBalance = CreditBalance(weeklyRemaining: weekly, purchasedRemaining: purchased, weeklyResetAt: resetAt)
        
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
        creditBalance.total >= cost
    }
    
    // MARK: - Job Methods
    
    func addJob(_ job: GenerationJob) {
        generationJobs.insert(job, at: 0)
        
        // Keep only last 30
        if generationJobs.count > 30 {
            // Remove the oldest job's files if it exists
            let oldestJob = generationJobs.last
            cleanupJobFiles(oldestJob)
            generationJobs.removeLast()
        }
    }
    
    func updateJobStatus(jobId: UUID, status: GenerationStatus) {
        if let index = generationJobs.firstIndex(where: { $0.id == jobId }) {
            generationJobs[index].status = status
            saveJobs() // Trigger save manually if needed, although didSet handles it
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
        if case .completed(let localURL) = job.status {
            try? FileManager.default.removeItem(at: localURL)
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
    
    func handleSubscriptionVerification(transactionId: String, apiClient: APIClient) async {
        do {
            try await apiClient.verifySubscription(transactionId: transactionId)
            isProSubscriber = true
            await refreshCreditBalance(apiClient: apiClient)
        } catch {
            print("Subscription verification failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Reset (for testing)
    
    func resetAll() {
        hasCompletedOnboarding = false
        isProSubscriber = false
        creditBalance = .zero
        generationJobs = []
    }
}
