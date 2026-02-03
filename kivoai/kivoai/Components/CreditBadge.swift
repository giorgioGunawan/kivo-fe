//
//  CreditBadge.swift
//  kivoai
//

import SwiftUI

struct CreditBadge: View {
    let cost: Int
    var showLabel: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.kivoCredits)
            
            Text("\(cost)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color.kivoCredits)
            
            if showLabel {
                Text("credits")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.kivoCredits.opacity(0.15))
        .clipShape(Capsule())
    }
}

struct CreditBalanceView: View {
    let balance: CreditBalance
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.kivoCredits)
                
                Text("Weekly: \(balance.weekly)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("·")
                .foregroundColor(Color.kivoTextTertiary)
            
            HStack(spacing: 4) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.kivoTextSecondary)
                
                Text("Purchased: \(balance.purchased)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.kivoCardBackground)
        .clipShape(Capsule())
    }
}

#Preview {
    ZStack {
        Color.kivoBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            CreditBadge(cost: 15)
            CreditBadge(cost: 25, showLabel: true)
            CreditBalanceView(balance: CreditBalance(weekly: 450, purchased: 100))
        }
    }
}
