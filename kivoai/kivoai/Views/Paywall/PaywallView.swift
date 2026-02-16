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

    var isOneTimeOffer: Bool = false

    @State private var selectedPlan: Plan
    @State private var isPurchasing: Bool = false
    @State private var purchaseError: String? = nil

    init(isOneTimeOffer: Bool = false) {
        self.isOneTimeOffer = isOneTimeOffer
        self._selectedPlan = State(initialValue: isOneTimeOffer ? .discounted : .weekly)
    }

    // MARK: - Plan

    enum Plan: String, CaseIterable {
        case weekly = "com.kivoai.weekly"
        case monthly = "com.kivoai.monthly"
        case discounted = "com.kivoai.weekly.discounted"

        var title: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .discounted: return "Weekly (20% Off)"
            }
        }

        var fallbackPrice: String {
            switch self {
            case .weekly: return "$8.99/week"
            case .monthly: return "$19.99/month"
            case .discounted: return "$6.99/week"
            }
        }
        
        var creditAmount: String {
            switch self {
            case .weekly, .discounted: return "500 credits / week"
            case .monthly: return "1500 credits / month"
            }
        }

        var badge: String? {
            switch self {
            case .monthly: return nil
            case .discounted: return "LIMITED OFFER"
            default: return nil
            }
        }
    }
    
    private var visiblePlans: [Plan] {
        if isOneTimeOffer {
            return [.discounted]
        } else {
            return [.weekly, .monthly]
        }
    }
    
    // MARK: - Discount Helper
    
    private var discountPercentage: String {
        let products = appEnvironment.storeKitManager.products
        
        // Try to get actual product prices
        if let weeklyProduct = products.first(where: { $0.id == Plan.weekly.rawValue }),
           let discountedProduct = products.first(where: { $0.id == Plan.discounted.rawValue }) {
            
            let weeklyPrice = NSDecimalNumber(decimal: weeklyProduct.price).doubleValue
            let discountedPrice = NSDecimalNumber(decimal: discountedProduct.price).doubleValue
            
            if weeklyPrice > 0 {
                let discount = 1.0 - (discountedPrice / weeklyPrice)
                let percentage = Int((discount * 100).rounded())
                return "\(percentage)%"
            }
        }
        
        // Fallback calculation based on hardcoded fallback prices if products fail to load
        // Weekly: 8.99, Discounted: 6.99 -> ~22%
        // But let's just default to a safe "22%" or just "20%" as previously hardcoded if logic fails?
        // Actually, let's calculate from the fallback strings to be robust or just return "20%" as a safe default.
        return "20%"
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.top, AppTheme.Spacing.xl)
                        .padding(.bottom, AppTheme.Spacing.xl)
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    // Benefits
                    if isOneTimeOffer {
                        discountCardSection
                            .padding(.bottom, AppTheme.Spacing.xl)
                    } else {
                        benefitsSection
                            .padding(.bottom, AppTheme.Spacing.xl)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    // Plans
                    if !isOneTimeOffer {
                        planSelectionSection
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.xl)
                    }

                    // CTA
                    actionSection
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.lg)

                    // Restore
                    if !isPurchasing {
                        restoreButton
                            .padding(.bottom, AppTheme.Spacing.xl)
                    }
                }
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
            .alert("Purchase Failed", isPresented: Binding(
                get: { purchaseError != nil },
                set: { if !$0 { purchaseError = nil } }
            ), actions: {
                Button("OK") { purchaseError = nil }
            }, message: {
                Text(purchaseError ?? "")
            })
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(isOneTimeOffer ? "One-time offer" : "Unlock Kivo Pro")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            if isOneTimeOffer {
                Text("Get \(discountPercentage) off your subscription forever.")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // Original tick-list for Main Paywall
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            BenefitTick(text: "Generate images at high quality")
            BenefitTick(text: "Access 20+ trendy templates")
            BenefitTick(text: "No watermarks on downloads")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // New Card Design for One-Time Offer
    private var discountCardSection: some View {
        VStack(spacing: 24) {
            ZStack {
                // Card
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.2), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 140)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                // Text inside card
                Text("\(discountPercentage) OFF\nFOREVER")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                
                // Sparkles (decorative)
                GeometryReader { geo in
                    // Top Left
                    Image(systemName: "sparkle")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: -10, y: 20)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: 10, y: -10)
                        
                    // Bottom Left
                    Image(systemName: "sparkle")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: 0, y: geo.size.height + 5)

                    // Top Right
                    Image(systemName: "sparkle")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: geo.size.width + 10, y: 40)
                        
                    Image(systemName: "sparkle")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: geo.size.width - 10, y: 100)
                        
                    // Bottom Right
                    Image(systemName: "sparkle")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: geo.size.width + 5, y: geo.size.height - 10)
                        
                    // More sparkles (Center-ish)
                    Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: 40, y: geo.size.height - 20)
                        
                    Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .position(x: geo.size.width - 40, y: 20)
                }
            }
            .padding(.horizontal, 40) // Give room for sparkles outside card
            
            // Pricing
            VStack(spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(displayPrice(for: .weekly)) // Original Price
                        .font(.title3)
                        .strikethrough()
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    
                    Text(displayPrice(for: .discounted))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }
                
                Text("Once you close your one-time offer, it's gone!")
                    .font(AppTheme.Typography.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
        }
    }

    private var planSelectionSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if appEnvironment.storeKitManager.isLoadingProducts {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            } else {
                ForEach(visiblePlans, id: \.self) { plan in
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
        VStack(spacing: AppTheme.Spacing.md) {
            if isPurchasing {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    // No Commitment line - Moved ABOVE button
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13.5, weight: .bold)) // Fixed typo: size 13.5
                        Text("No Commitment. Cancel Anytime") // Fixed typo: Commctment -> Commitment, Anytame -> Anytime
                            .font(.system(size: 13.5, weight: .semibold)) // Fixed size to match user intent
                    }
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        handlePurchase()
                    }) {
                        VStack(spacing: 2) {
                            Text(ctaTitle)
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(AppTheme.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                        .shadow(color: AppTheme.Colors.accent.opacity(0.2), radius: 8, x: 0, y: 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(appEnvironment.storeKitManager.isLoadingProducts)
                }

                legalText
            }
        }
    }
    
    private var ctaTitle: String {
        return isOneTimeOffer ? "Claim Offer" : "Upgrade"
    }

    private var legalText: some View {
        Text("Cancel anytime. Payment charged to Apple Account. Auto-renews unless canceled 24h before end.")
            .font(.caption2)
            .foregroundStyle(AppTheme.Colors.textSecondary) // Changed from textTertiary to textSecondary
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    private var restoreButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            handleRestore()
        }) {
            Text("Restore Purchases")
                .font(AppTheme.Typography.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
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
                try await appState.handleSubscriptionVerification(
                    transactionId: originalTransactionId,
                    productId: product.id,
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

    private func handleRestore() {
        isPurchasing = true
        Task {
            do {
                let transactionId = try await appEnvironment.storeKitManager.restorePurchases()
                try await appState.handleSubscriptionVerification(
                    transactionId: transactionId,
                    apiClient: appEnvironment.apiClient
                )
                await MainActor.run {
                    isPurchasing = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    purchaseError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Components

struct BenefitTick: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(AppTheme.Colors.accent)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            
            Spacer()
        }
    }
}

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
            HStack(spacing: AppTheme.Spacing.md) {
                // Radio Circle
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
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(plan.creditAmount)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Text(displayPrice)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.separator, lineWidth: isSelected ? 2 : 1)
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
