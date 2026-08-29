import SwiftUI

/// Paywall sheet presented from Profile/Settings. Does not require OnboardingViewModel.
struct SettingsPaywallSheet: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: Plan = .yearly
    @State private var showContent = false
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    enum Plan: String {
        case monthly, yearly
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ZantMeshBackground()

                VStack(spacing: 0) {
                    Spacer()

                    // Title
                    Text(Strings.Onboarding.unlockPotential)
                        .font(DesignTokens.Typography.title1)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxxl)

                    // Premium features
                    VStack(spacing: DesignTokens.Spacing.md) {
                        premiumFeatureRow(icon: "lock.shield.fill", title: Strings.Onboarding.unbreakableFocusMode)
                        premiumFeatureRow(icon: "wind", title: Strings.Onboarding.smartInterventions)
                        premiumFeatureRow(icon: "chart.bar.fill", title: Strings.Onboarding.fullAnalytics)
                        premiumFeatureRow(icon: "diamond.fill", title: Strings.Onboarding.allGemTypes)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .opacity(showContent ? 1 : 0)

                    Spacer()

                    // Plan selector
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        planCard(
                            plan: .yearly,
                            price: AppConstants.yearlyPrice,
                            period: "/year",
                            badge: Strings.Onboarding.save50,
                            trialText: Strings.Onboarding.freeTrialText(AppConstants.freeTrialDays)
                        )

                        planCard(
                            plan: .monthly,
                            price: AppConstants.monthlyPrice,
                            period: "/month",
                            badge: nil,
                            trialText: nil
                        )
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xl)

                    // CTA
                    VStack(spacing: DesignTokens.Spacing.md) {
                        ZantButton(
                            .glass,
                            title: selectedPlan == .yearly
                                ? Strings.Onboarding.startFreeTrial
                                : Strings.Onboarding.subscribe,
                            isLoading: isPurchasing
                        ) {
                            purchasePlan()
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .padding(.bottom, DesignTokens.Spacing.lg)
                    .opacity(showContent ? 1 : 0)

                    if let purchaseError {
                        Text(purchaseError)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.error)
                            .padding(.bottom, DesignTokens.Spacing.sm)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.General.cancel) { dismiss() }
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }
            }
        }
        .onFirstAppear {
            withAnimation(DesignTokens.Animation.smooth) {
                showContent = true
            }
        }
    }

    // MARK: - Subviews

    private func premiumFeatureRow(icon: String, title: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(DesignTokens.Colors.accent)
                .frame(width: 28)

            Text(title)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Colors.textPrimary)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DesignTokens.Colors.success)
        }
    }

    private func planCard(
        plan: Plan,
        price: String,
        period: String,
        badge: String?,
        trialText: String?
    ) -> some View {
        Button {
            withAnimation(DesignTokens.Animation.quick) {
                selectedPlan = plan
            }
            HapticManager.light()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(plan == .yearly ? Strings.Onboarding.yearly : Strings.Onboarding.monthly)
                            .font(DesignTokens.Typography.headline)
                            .foregroundStyle(DesignTokens.Colors.textPrimary)

                        if let badge {
                            Text(badge)
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Colors.textPrimary)
                                .padding(.horizontal, DesignTokens.Spacing.sm)
                                .padding(.vertical, DesignTokens.Spacing.xxs)
                                .background(DesignTokens.Colors.success)
                                .clipShape(Capsule())
                        }
                    }

                    if let trialText {
                        Text(trialText)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.accent)
                    }
                }

                Spacer()

                Text("\(price)\(period)")
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
            }
            .padding(DesignTokens.Spacing.lg)
            .if(selectedPlan == plan) { view in
                view.glassEffect(
                    .regular.tint(DesignTokens.Colors.accent.opacity(0.3)).interactive(),
                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                )
            }
            .if(selectedPlan != plan) { view in
                view
                    .background(DesignTokens.Colors.surfaceGlass)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func purchasePlan() {
        isPurchasing = true
        purchaseError = nil
        let productID = selectedPlan == .yearly
            ? AppConstants.yearlyProductID
            : AppConstants.monthlyProductID

        Task {
            defer { isPurchasing = false }
            let service = StoreKitService.shared
            await service.loadProducts()
            do {
                let success = try await service.purchase(productID: productID)
                if success {
                    HapticManager.success()
                    appState.isPremium = true
                    dismiss()
                }
            } catch {
                purchaseError = Strings.Onboarding.purchaseFailed
                HapticManager.error()
            }
        }
    }
}
