//
//  PaywallView.swift
//  kivoai
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: Plan = .weekly
    @State private var isPurchasing: Bool = false
    @State private var purchaseError: String? = nil

    // MARK: - Plan

    enum Plan: String, CaseIterable {
        case weekly = "com.kivoai.weekly"
        case monthly = "com.kivoai.monthly"
        case discounted = "com.kivoai.weekly.discounted"

        var title: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .discounted: return "One-Time Offer"
            }
        }

        var fallbackPrice: String {
            switch self {
            case .weekly: return "$8.99/week"
            case .monthly: return "$19.99/month"
            case .discounted: return "$6.99/week"
            }
        }

        var description: String {
            switch self {
            case .weekly: return "500 credits · renews weekly"
            case .monthly: return "500 credits · renews monthly"
            case .discounted: return "500 credits · limited time price"
            }
        }

        var badge: String? {
            switch self {
            case .monthly: return "Best Value"
            case .discounted: return "Special Offer"
            default: return nil
            }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    headerSection
                    benefitsSection
                    planSelectionSection
                    actionSection
                    legalText
                    Spacer().frame(height: AppTheme.Spacing.xl)
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
                    .disabled(isPurchasing)
                }
            }
            .alert("Purchase Failed", isPresented: .constant(purchaseError != nil), actions: {
                Button("OK") { purchaseError = nil }
            }, message: {
                Text(purchaseError ?? "")
            })
        }
    }

    // MARK: - Sections

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

    private var benefitsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            BenefitRow(icon: "🪙", title: "500 Weekly Credits", description: "Refresh every week", isEmoji: true)
            BenefitRow(icon: "square.grid.2x2.fill", title: "All Templates", description: "Access every template")
            BenefitRow(icon: "wand.and.stars", title: "Priority Generation", description: "Skip the queue")
            BenefitRow(icon: "video.fill", title: "Video Coming Soon", description: "Be first to try")
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
    }

    private var planSelectionSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if appEnvironment.storeKitManager.isLoadingProducts {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            } else {
                ForEach(Plan.allCases, id: \.self) { plan in
                    PlanCard(
                        plan: plan,
                        displayPrice: displayPrice(for: plan),
                        isSelected: selectedPlan == plan
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPlan = plan
                        }
                    }
                }
            }
        }
    }

    private var actionSection: some View {
        Group {
            if isPurchasing {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .padding()
            } else {
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    handlePurchase()
                }) {
                    Text("Start Pro · \(displayPrice(for: selectedPlan))")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(appEnvironment.storeKitManager.isLoadingProducts)
            }
        }
    }

    private var legalText: some View {
        Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.textTertiary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Helpers

    private func displayPrice(for plan: Plan) -> String {
        let products = appEnvironment.storeKitManager.products
        if let product = products.first(where: { $0.id == plan.rawValue }) {
            return product.displayPrice
        }
        return plan.fallbackPrice
    }

    // MARK: - Purchase Flow

    private func handlePurchase() {
        let manager = appEnvironment.storeKitManager
        guard let product = manager.products.first(where: { $0.id == selectedPlan.rawValue }) else {
            purchaseError = "Product unavailable. Please try again."
            return
        }

        isPurchasing = true
        Task {
            do {
                let originalTransactionId = try await manager.purchase(product)
                await appState.handleSubscriptionVerification(
                    transactionId: originalTransactionId,
                    apiClient: appEnvironment.apiClient
                )
                await MainActor.run {
                    isPurchasing = false
                    dismiss()
                }
            } catch StoreKitManager.StoreError.userCancelled {
                await MainActor.run { isPurchasing = false }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    purchaseError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    var isEmoji: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent.opacity(0.1))
                    .frame(width: 40, height: 40)

                if isEmoji {
                    Text(icon)
                        .font(.system(size: 20))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.accent)
                }
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
    let displayPrice: String
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

                        if let badge = plan.badge {
                            Text(badge)
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

                Text(displayPrice)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textPrimary)

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
        .environmentObject(AppEnvironment())
}
