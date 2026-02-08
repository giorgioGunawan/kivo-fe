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
    
    @Published var generationJobs: [GenerationJob] = []
    
    @Published var showingPaywall: Bool = false
    @Published var showingCreditsSheet: Bool = false
    @Published var showingCustomCreation: Bool = false
    @Published var tabBarHidden: Bool = false
    
    // MARK: - Keys
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isProSubscriber = "isProSubscriber"
        static let weeklyCredits = "weeklyCredits"
        static let purchasedCredits = "purchasedCredits"
        static let weeklyResetAt = "weeklyResetAt"
    }
    
    // MARK: - Init
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        self.isProSubscriber = UserDefaults.standard.bool(forKey: Keys.isProSubscriber)
        
        let weekly = UserDefaults.standard.integer(forKey: Keys.weeklyCredits)
        let purchased = UserDefaults.standard.integer(forKey: Keys.purchasedCredits)
        let resetAt = UserDefaults.standard.string(forKey: Keys.weeklyResetAt)
        self.creditBalance = CreditBalance(weeklyRemaining: weekly, purchasedRemaining: purchased, weeklyResetAt: resetAt)
    }
    
    // MARK: - Credit Methods
    
    func refreshCreditBalance(apiClient: APIClient) async {
        do {
            let backendBalance = try await apiClient.fetchBalance()
            self.creditBalance = backendBalance
            // If user has credits or is identified as pro by the backend, we might want to update isProSubscriber locally too if needed
            // For now, let's just sync the balance
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
    }
    
    func updateJobStatus(jobId: UUID, status: GenerationStatus) {
        if let index = generationJobs.firstIndex(where: { $0.id == jobId }) {
            generationJobs[index].status = status
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
