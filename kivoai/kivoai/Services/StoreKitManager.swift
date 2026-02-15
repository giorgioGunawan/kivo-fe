//
//  StoreKitManager.swift
//  kivoai
//

import StoreKit
import Combine

@MainActor
final class StoreKitManager: ObservableObject {

    // MARK: - Product IDs

    enum ProductID {
        static let weekly = "com.kivoai.weekly"
        static let monthly = "com.kivoai.monthly"
        static let weeklyDiscounted = "com.kivoai.weekly.discounted"
        static let all: [String] = [weekly, monthly, weeklyDiscounted]

        static let credits150 = "com.kivoai.credits.150"
        static let credits500 = "com.kivoai.credits.500"
        static let credits1000 = "com.kivoai.credits.1000"
        static let allConsumables: [String] = [credits150, credits500, credits1000]
    }

    // MARK: - Published State

    @Published var products: [Product] = []
    @Published var consumableProducts: [Product] = []
    @Published var isLoadingProducts: Bool = false
    @Published var activeSubscriptionID: String? = nil

    // MARK: - Private

    private var transactionListenerTask: Task<Void, Never>?

    // MARK: - Init / Deinit

    init() {
        transactionListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await refreshActiveSubscription()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let allIDs = Set(ProductID.all + ProductID.allConsumables)
            let fetched = try await Product.products(for: allIDs)

            let subOrder = [ProductID.weekly, ProductID.monthly, ProductID.weeklyDiscounted]
            products = subOrder.compactMap { id in fetched.first(where: { $0.id == id }) }

            let consumableOrder = [ProductID.credits150, ProductID.credits500, ProductID.credits1000]
            consumableProducts = consumableOrder.compactMap { id in fetched.first(where: { $0.id == id }) }
        } catch {
            print("[StoreKit] Failed to load products: \(error)")
        }
    }

    // MARK: - Active Subscription

    func refreshActiveSubscription() async {
        var activeID: String?
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if ProductID.all.contains(transaction.productID) {
                    activeID = transaction.productID
                    break
                }
            }
        }
        self.activeSubscriptionID = activeID
    }

    // MARK: - Purchase (Subscription)

    /// Initiates a subscription purchase and returns the `originalTransactionId` on success.
    func purchase(_ product: Product) async throws -> String {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue
            await transaction.finish()
            await refreshActiveSubscription()
            return String(transaction.originalID)
        case .userCancelled:
            throw StoreError.userCancelled
        case .pending:
            throw StoreError.pending
        @unknown default:
            throw StoreError.unknown
        }
    }

    // MARK: - Purchase (Consumable)

    struct ConsumablePurchaseInfo {
        let originalTransactionId: String
        let transactionId: String
        let productId: String
    }

    /// Initiates a consumable credit purchase. Finishes the transaction on success.
    /// Caller is responsible for verifying with the backend using the returned IDs.
    func purchaseConsumable(_ product: Product) async throws -> ConsumablePurchaseInfo {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue
            await transaction.finish()
            return ConsumablePurchaseInfo(
                originalTransactionId: String(transaction.originalID),
                transactionId: String(transaction.id),
                productId: transaction.productID
            )
        case .userCancelled:
            throw StoreError.userCancelled
        case .pending:
            throw StoreError.pending
        @unknown default:
            throw StoreError.unknown
        }
    }

    // MARK: - Restore

    func restorePurchases() async throws -> String {
        try await AppStore.sync()
        await refreshActiveSubscription()

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if ProductID.all.contains(transaction.productID) {
                    return String(transaction.originalID)
                }
            }
        }
        throw StoreError.noPurchasesToRestore
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    // Auto-finish subscriptions only.
                    // Consumables are finished inside purchaseConsumable() after IDs are captured.
                    if ProductID.all.contains(transaction.productID) {
                        await transaction.finish()
                        await self?.refreshActiveSubscription()
                    }
                }
            }
        }
    }

    // MARK: - Errors

    enum StoreError: LocalizedError {
        case failedVerification
        case userCancelled
        case pending
        case noPurchasesToRestore
        case unknown

        var errorDescription: String? {
            switch self {
            case .failedVerification: return "Transaction verification failed."
            case .userCancelled: return nil
            case .pending: return "Your purchase is pending approval."
            case .noPurchasesToRestore: return "No active subscription found to restore."
            case .unknown: return "An unknown error occurred."
            }
        }
    }
}
