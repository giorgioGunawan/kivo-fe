//
//  CreditBalance.swift
//  kivoai
//

import Foundation

struct CreditBalance: Codable, Equatable {
    let weeklyRemaining: Int
    let purchasedRemaining: Int
    let lastWeeklyRefreshAt: String?
    let subscriptionExpiresAt: String?
    /// Derived from the backend subscriptions table — never set client-side.
    let isProSubscriber: Bool

    var total: Int { weeklyRemaining + purchasedRemaining }

    static let zero = CreditBalance(
        weeklyRemaining: 0,
        purchasedRemaining: 0,
        lastWeeklyRefreshAt: nil,
        subscriptionExpiresAt: nil,
        isProSubscriber: false
    )
}
