import Foundation
import StoreKit
import Observation

// MARK: - Paywall View Model

@Observable
final class PaywallViewModel {

    // MARK: - Published State

    private(set) var products: [Product] = []
    var isProcessing = false
    var isPurchaseSuccessful = false
    var showError = false
    var errorMessage = ""

    // MARK: - Dependencies

    private let storeKitService: StoreKitService
    private let analyticsService: AnalyticsService

    // MARK: - Initialization

    init(
        storeKitService: StoreKitService = .shared,
        analyticsService: AnalyticsService = .shared
    ) {
        self.storeKitService = storeKitService
        self.analyticsService = analyticsService
    }

    // MARK: - Public Methods

    func loadProducts() async {
        await storeKitService.loadProducts()
        self.products = storeKitService.products
    }

    func purchase(plan: SubscriptionPlan) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let success = try await storeKitService.purchase(productID: plan.productID)

            if success {
                isPurchaseSuccessful = true
                analyticsService.track(.subscriptionPurchased(plan: plan.displayName))
                HapticManager.success()
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            analyticsService.track(.subscriptionPurchaseFailed(error: error.localizedDescription))
        }
    }

    func restorePurchases() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await storeKitService.restorePurchases()

            if storeKitService.isPremium {
                isPurchaseSuccessful = true
                analyticsService.track(.subscriptionRestored)
                HapticManager.success()
            } else {
                showError = true
                errorMessage = "No active subscriptions found."
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }

    func trackPaywallShown(source: PaywallSource) {
        analyticsService.track(.paywallShown(source: source.rawValue))
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        products.first(where: { $0.id == plan.productID })
    }
}

// MARK: - Product Extension

extension Product {
    var priceValue: Double {
        NSDecimalNumber(decimal: self.price).doubleValue
    }
}
