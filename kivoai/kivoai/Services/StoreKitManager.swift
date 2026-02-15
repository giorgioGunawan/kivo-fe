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
    }

    // MARK: - Published State

    @Published var products: [Product] = []
    @Published var isLoadingProducts: Bool = false

    // MARK: - Private

    private var transactionListenerTask: Task<Void, Never>?

    // MARK: - Init / Deinit

    init() {
        transactionListenerTask = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let fetched = try await Product.products(for: Set(ProductID.all))
            // Sort into a stable order: weekly → monthly → discounted
            let order = [ProductID.weekly, ProductID.monthly, ProductID.weeklyDiscounted]
            products = order.compactMap { id in fetched.first(where: { $0.id == id }) }
        } catch {
            print("[StoreKit] Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    /// Initiates a purchase and returns the `originalTransactionId` as a String on success.
    func purchase(_ product: Product) async throws -> String {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue
            await transaction.finish()
            return String(transaction.originalID)
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
        Task.detached(priority: .background) {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
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
