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

    @State private var selectedPackageId: String? = StoreKitManager.ProductID.credits500
    @State private var isPurchasing: Bool = false
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
        CreditPackage(id: StoreKitManager.ProductID.credits500,  credits: 500,  fallbackPrice: "$6.99",  badge: nil),
        CreditPackage(id: StoreKitManager.ProductID.credits1000, credits: 1000, fallbackPrice: "$11.99", badge: nil),
    ]
    
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
                    benefitsSection
                        .padding(.bottom, AppTheme.Spacing.xl)
                        .padding(.horizontal, AppTheme.Spacing.xl)

                    // Packages
                    packagesSection
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.xl)

                    // CTA
                    actionSection
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.lg)
                    
                    // Disclaimer
                    tagline
                        .padding(.bottom, AppTheme.Spacing.xl)
                }
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
            .onAppear {
                // Ensure a valid selection on appear
                if selectedPackageId == nil {
                    selectedPackageId = packages.first?.id
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("Top Up Credits")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Running low? Add more credits instantly.\nThey never expire.")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            BenefitTick(text: "One-time purchase, no subscription")
            BenefitTick(text: "Credits never expire")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var packagesSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if appEnvironment.storeKitManager.isLoadingProducts {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
            } else {
                ForEach(packages) { package in
                    PackageOptionRow(
                        package: package,
                        displayPrice: displayPrice(for: package.id),
                        isSelected: selectedPackageId == package.id,
                        isEnabled: canBuy(package)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPackageId = package.id
                        }
                    }
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
    
    private var actionSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if isPurchasing {
                ProgressView()
                    .tint(AppTheme.Colors.accent)
                    .padding()
            } else {
                Button(action: {
                    if let id = selectedPackageId, let package = packages.first(where: { $0.id == id }) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        handlePurchase(package: package)
                    }
                }) {
                    Text("Add Credits")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(isPurchaseDisabled ? AppTheme.Colors.textTertiary : AppTheme.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                        .shadow(color: isPurchaseDisabled ? Color.clear : AppTheme.Colors.accent.opacity(0.2), radius: 8, x: 0, y: 4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isPurchaseDisabled || appEnvironment.storeKitManager.isLoadingProducts)
            }
        }
    }

    private var tagline: some View {
        Text("Purchased credits are used only after your weekly subscription credits are exhausted.")
            .font(.caption2)
            .foregroundStyle(AppTheme.Colors.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    // MARK: - Helpers

    private var isAtMaxLimit: Bool {
        appState.creditBalance.purchasedRemaining >= maxPurchasedCredits
    }
    
    private var isPurchaseDisabled: Bool {
        guard let id = selectedPackageId, let package = packages.first(where: { $0.id == id }) else { return true }
        return !canBuy(package)
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
                    dismiss()
                }
            } catch StoreKitManager.StoreError.userCancelled {
                await MainActor.run {
                    isPurchasing = false
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

struct PackageOptionRow: View {
    let package: ExtraCreditsSheet.CreditPackage
    let displayPrice: String
    let isSelected: Bool
    let isEnabled: Bool
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
                .opacity(isEnabled ? 1 : 0.5)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(package.credits) Credits")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isEnabled ? AppTheme.Colors.textPrimary : AppTheme.Colors.textTertiary)
                        
                        if let badge = package.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if !isEnabled {
                        Text("Limit reached")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
                }
                
                Spacer()
                
                Text(displayPrice)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isSelected ? AppTheme.Colors.accent : (isEnabled ? AppTheme.Colors.textPrimary : AppTheme.Colors.textTertiary))
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
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
    }
}

// MARK: - Previews

#Preview {
    ExtraCreditsSheet()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
