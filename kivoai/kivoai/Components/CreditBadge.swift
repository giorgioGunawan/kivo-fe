//
//  CreditBadge.swift
//  kivoai
//
//  Minimal credit display components.
//

import SwiftUI

struct CreditBadge: View {
    let cost: Int
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xxs) {
            Image(systemName: "bolt.fill")
                .font(.system(size: isCompact ? 10 : 12, weight: .semibold))
            
            Text("\(cost)")
                .font(isCompact ? AppTheme.Typography.caption2 : AppTheme.Typography.footnote)
                .fontWeight(.semibold)
        }
        .foregroundStyle(AppTheme.Colors.credits)
        .padding(.horizontal, isCompact ? AppTheme.Spacing.xs : AppTheme.Spacing.sm)
        .padding(.vertical, isCompact ? 4 : AppTheme.Spacing.xxs)
        .background(AppTheme.Colors.credits.opacity(0.12))
        .clipShape(Capsule())
    }
}

struct CreditBalanceView: View {
    let balance: CreditBalance
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            // Weekly
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.credits)
                
                Text("Weekly: \(balance.weeklyRemaining)")
                    .font(AppTheme.Typography.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            
            Text("·")
                .foregroundStyle(AppTheme.Colors.textTertiary)
            
            // Purchased
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                Text("Purchased: \(balance.purchasedRemaining)")
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.background)
        .clipShape(Capsule())
        .shadow(color: AppTheme.Shadow.subtle, radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        CreditBadge(cost: 10)
        CreditBadge(cost: 5, isCompact: true)
        CreditBalanceView(balance: CreditBalance(weeklyRemaining: 445, purchasedRemaining: 100, weeklyResetAt: nil))
    }
    .padding()
    .background(AppTheme.Colors.groupedBackground)
}
