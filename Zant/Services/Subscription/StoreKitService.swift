import Foundation
import os
import StoreKit

/// StoreKit 2 subscription management.
final class StoreKitService: StoreKitServiceProtocol, @unchecked Sendable {

    static let shared = StoreKitService()

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.zant", category: "StoreKitService")

    private(set) var products: [Product] = []
    private(set) var isPremium: Bool = false
    private(set) var isLoadingProducts: Bool = false

    private var transactionListenerTask: Task<Void, Never>?

    private init() {
        isPremium = UserDefaultsManager.shared.isPremium
        transactionListenerTask = listenForTransactions()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            products = try await Product.products(for: [
                AppConstants.monthlyProductID,
                AppConstants.yearlyProductID,
            ])
        } catch {
            Self.logger.error("Failed to load products: \(error.localizedDescription)")
        }
    }

    func purchase(productID: String) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productID }) else {
            return false
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePremiumStatus()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePremiumStatus()
    }

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await self?.updatePremiumStatus()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    @MainActor
    private func updatePremiumStatus() async {
        var hasActiveSubscription = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productType == .autoRenewable {
                hasActiveSubscription = true
                break
            }
        }
        isPremium = hasActiveSubscription
        UserDefaultsManager.shared.isPremium = hasActiveSubscription
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            "Transaction verification failed."
        }
    }
}
