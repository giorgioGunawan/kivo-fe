//
//  PaywallView.swift
//  kivoai
//
//  Clean paywall with progressive disclosure.
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlan: Plan = .pro
    
    enum Plan: String, CaseIterable {
        case pro
        case credits
        
        var title: String {
            switch self {
            case .pro: return "Pro Subscription"
            case .credits: return "Credit Pack"
            }
        }
        
        var price: String {
            switch self {
            case .pro: return "$9.99/week"
            case .credits: return "$4.99"
            }
        }
        
        var description: String {
            switch self {
            case .pro: return "500 credits weekly"
            case .credits: return "100 credits one-time"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Benefits
                    benefitsSection
                    
                    // Plans
                    planSelectionSection
                    
                    // CTA
                    purchaseButton
                    
                    // Legal
                    legalText
                    
                    Spacer()
                        .frame(height: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.groupedBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.credits.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.credits)
            }
            
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Unlock Kivo Pro")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text("Create unlimited AI masterpieces")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }
    
    // MARK: - Benefits
    
    private var benefitsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            BenefitRow(icon: "bolt.fill", title: "500 Weekly Credits", description: "Refresh every week")
            BenefitRow(icon: "square.grid.2x2.fill", title: "All Templates", description: "Access every template")
            BenefitRow(icon: "wand.and.stars", title: "Priority Generation", description: "Skip the queue")
            BenefitRow(icon: "video.fill", title: "Video Coming Soon", description: "Be first to try")
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
    }
    
    // MARK: - Plans
    
    private var planSelectionSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ForEach(Plan.allCases, id: \.self) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPlan = plan
                    }
                }
            }
        }
    }
    
    // MARK: - Purchase
    
    private var purchaseButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            handlePurchase()
        }) {
            Text(selectedPlan == .pro ? "Start Pro" : "Buy Credits")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.Colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var legalText: some View {
        Text("This is a mock paywall for development. No real payment will be processed.")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.textTertiary)
            .multilineTextAlignment(.center)
    }
    
    private func handlePurchase() {
        switch selectedPlan {
        case .pro:
            appState.purchasePro()
        case .credits:
            appState.addPurchasedCredits(100)
        }
        dismiss()
    }
}

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text(description)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Plan Card

struct PlanCard: View {
    let plan: PaywallView.Plan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(plan.title)
                            .font(AppTheme.Typography.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        
                        if plan == .pro {
                            Text("Best Value")
                                .font(AppTheme.Typography.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(plan.description)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Text(plan.price)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textPrimary)
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.separator, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(AppTheme.Colors.accent)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.leading, AppTheme.Spacing.sm)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .stroke(isSelected ? AppTheme.Colors.accent : Color.clear, lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
