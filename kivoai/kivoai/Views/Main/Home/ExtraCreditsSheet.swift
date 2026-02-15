//
//  ExtraCreditsSheet.swift
//  kivoai
//
//  One-time consumable credit top-ups. Credits never expire and are used
//  only after the user's weekly subscription credits are exhausted.
//

import SwiftUI
import StoreKit

struct ExtraCreditsSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing: Bool = false
    @State private var purchasingId: String? = nil
    @State private var purchaseError: String? = nil

    private let maxPurchasedCredits = 2000

    // MARK: - Package Model

    struct CreditPackage: Identifiable {
        let id: String           // StoreKit product ID
        let credits: Int
        let fallbackPrice: String
        let badge: String?
    }

    private let packages: [CreditPackage] = [
        CreditPackage(id: StoreKitManager.ProductID.credits150,  credits: 150,  fallbackPrice: "$2.99",  badge: nil),
        CreditPackage(id: StoreKitManager.ProductID.credits500,  credits: 500,  fallbackPrice: "$6.99",  badge: "Best Value"),
        CreditPackage(id: StoreKitManager.ProductID.credits1000, credits: 1000, fallbackPrice: "$11.99", badge: nil),
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    headerSection
                    packagesSection
                    tagline
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
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.credits.opacity(0.15))
                    .frame(width: 80, height: 80)
                Text("🪙")
                    .font(.system(size: 36))
            }

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Top Up Credits")
                    .font(AppTheme.Typography.title)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text("One-time purchase · Never expire")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - Packages

    private var packagesSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            if appEnvironment.storeKitManager.isLoadingProducts {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
            } else {
                ForEach(packages) { package in
                    packageRow(for: package)
                }
            }

            if isAtMaxLimit {
                Text("Max credit limit reached (2,000). Use your credits before buying more.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, AppTheme.Spacing.xs)
            }
        }
    }

    private func packageRow(for package: CreditPackage) -> some View {
        let purchasable = canBuy(package) && !isPurchasing
        let isThisPurchasing = purchasingId == package.id

        return HStack(spacing: AppTheme.Spacing.md) {
            // Credit amount + badge
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text("\(package.credits) Credits")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(purchasable ? AppTheme.Colors.textPrimary : AppTheme.Colors.textTertiary)

                    if let badge = package.badge {
                        Text(badge)
                            .font(AppTheme.Typography.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.accent)
                            .clipShape(Capsule())
                    }
                }

                // Contextual disabled reason
                if !canBuy(package) {
                    Text(isAtMaxLimit ? "Max limit reached" : "Would exceed 2,000 limit")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }

            Spacer()

            // Buy button / spinner
            if isThisPurchasing {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .frame(width: 76)
            } else {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    handlePurchase(package: package)
                } label: {
                    Text(displayPrice(for: package.id))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(purchasable ? .white : AppTheme.Colors.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, 10)
                        .background(purchasable ? LinearGradient.accentGradient : LinearGradient(colors: [AppTheme.Colors.fill], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!purchasable)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(AppTheme.Colors.separator.opacity(purchasable ? 0 : 0.5), lineWidth: 1)
        )
        .opacity(purchasable ? 1.0 : 0.55)
    }

    // MARK: - Tagline

    private var tagline: some View {
        Text("Credits never expire. Used after your weekly/monthly plan.")
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.textTertiary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private var isAtMaxLimit: Bool {
        appState.creditBalance.purchasedRemaining >= maxPurchasedCredits
    }

    private func canBuy(_ package: CreditPackage) -> Bool {
        !isAtMaxLimit &&
        (appState.creditBalance.purchasedRemaining + package.credits) <= maxPurchasedCredits
    }

    private func displayPrice(for productId: String) -> String {
        if let product = appEnvironment.storeKitManager.consumableProducts.first(where: { $0.id == productId }) {
            return product.displayPrice
        }
        return packages.first(where: { $0.id == productId })?.fallbackPrice ?? "—"
    }

    // MARK: - Purchase

    private func handlePurchase(package: CreditPackage) {
        guard let product = appEnvironment.storeKitManager.consumableProducts.first(where: { $0.id == package.id }) else {
            purchaseError = "Product unavailable. Please try again."
            return
        }

        isPurchasing = true
        purchasingId = package.id

        Task {
            do {
                let info = try await appEnvironment.storeKitManager.purchaseConsumable(product)
                try await appEnvironment.apiClient.verifyConsumablePurchase(
                    originalTransactionId: info.originalTransactionId,
                    transactionId: info.transactionId,
                    productId: info.productId
                )
                await appState.refreshCreditBalance(apiClient: appEnvironment.apiClient)
                await MainActor.run {
                    isPurchasing = false
                    purchasingId = nil
                    dismiss()
                }
            } catch StoreKitManager.StoreError.userCancelled {
                await MainActor.run {
                    isPurchasing = false
                    purchasingId = nil
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    purchasingId = nil
                    purchaseError = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ExtraCreditsSheet()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
