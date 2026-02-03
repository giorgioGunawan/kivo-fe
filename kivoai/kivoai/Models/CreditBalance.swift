//
//  CreditBalance.swift
//  kivoai
//

import Foundation

struct CreditBalance: Codable, Equatable {
    var weekly: Int
    var purchased: Int
    
    var total: Int { weekly + purchased }
    
    static let zero = CreditBalance(weekly: 0, purchased: 0)
    static let defaultProWeekly = CreditBalance(weekly: 500, purchased: 0)
    
    mutating func consume(_ amount: Int) -> Bool {
        guard total >= amount else { return false }
        
        var remaining = amount
        
        // Use weekly credits first
        if weekly >= remaining {
            weekly -= remaining
            return true
        } else {
            remaining -= weekly
            weekly = 0
        }
        
        // Then use purchased credits
        purchased -= remaining
        return true
    }
}
