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
            if isProSubscriber {
                ensureInitialCreditsIfNeeded()
            }
        }
    }
    
    @Published var creditBalance: CreditBalance {
        didSet {
            UserDefaults.standard.set(creditBalance.weekly, forKey: Keys.weeklyCredits)
            UserDefaults.standard.set(creditBalance.purchased, forKey: Keys.purchasedCredits)
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
    }
    
    // MARK: - Init
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        self.isProSubscriber = UserDefaults.standard.bool(forKey: Keys.isProSubscriber)
        
        let weekly = UserDefaults.standard.integer(forKey: Keys.weeklyCredits)
        let purchased = UserDefaults.standard.integer(forKey: Keys.purchasedCredits)
        self.creditBalance = CreditBalance(weekly: weekly, purchased: purchased)
    }
    
    // MARK: - Credit Methods
    
    func ensureInitialCreditsIfNeeded() {
        if isProSubscriber && creditBalance.weekly == 0 {
            creditBalance.weekly = 500
        }
    }
    
    func consumeCredits(cost: Int) -> Bool {
        guard creditBalance.total >= cost else { return false }
        var balance = creditBalance
        let success = balance.consume(cost)
        if success {
            creditBalance = balance
        }
        return success
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
        if isProSubscriber {
            ensureInitialCreditsIfNeeded()
        }
    }
    
    // MARK: - Mock Pro Purchase
    
    func purchasePro() {
        isProSubscriber = true
        creditBalance.weekly = 500
    }
    
    func addPurchasedCredits(_ amount: Int) {
        creditBalance.purchased += amount
    }
    
    // MARK: - Reset (for testing)
    
    func resetAll() {
        hasCompletedOnboarding = false
        isProSubscriber = false
        creditBalance = .zero
        generationJobs = []
    }
}
