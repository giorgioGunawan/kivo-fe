//
//  CreditBalance.swift
//  kivoai
//

import Foundation

struct CreditBalance: Codable, Equatable {
    let weeklyRemaining: Int
    let purchasedRemaining: Int
    let weeklyResetAt: String?
    
    var total: Int { weeklyRemaining + purchasedRemaining }
    
    static let zero = CreditBalance(weeklyRemaining: 0, purchasedRemaining: 0, weeklyResetAt: nil)
}
