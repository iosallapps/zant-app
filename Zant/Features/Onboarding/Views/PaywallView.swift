import SwiftUI

/// Onboarding Screen 5: Premium paywall with plan selection. No scroll.
struct PaywallView: View {

    @Bindable var viewModel: OnboardingViewModel
    @Environment(AppState.self) private var appState

    @State private var selectedPlan: Plan = .yearly
    @State private var showContent = false

    enum Plan: String {
        case monthly, yearly
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxxl)

                    // Title
                    Text("Unlock Your\nFull Potential")
                        .font(DesignTokens.Typography.title1)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxxl)

                    // Premium features — compact
                    VStack(spacing: DesignTokens.Spacing.md) {
                        premiumFeatureRow(
                            icon: "lock.shield.fill",
                            title: "Unbreakable Focus Mode"
                        )
                        premiumFeatureRow(
                            icon: "wind",
                            title: "Smart Interventions"
                        )
                        premiumFeatureRow(
                            icon: "chart.bar.fill",
                            title: "Full Analytics & Insights"
                        )
                        premiumFeatureRow(
                            icon: "trophy.fill",
                            title: "All 7 Cup Types"
                        )
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxl)

                    // Plan selector
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        planCard(
                            plan: .yearly,
                            price: AppConstants.yearlyPrice,
                            period: "/year",
                            badge: "Save 50%",
                            trialText: "\(AppConstants.freeTrialDays)-day free trial, then "
                                + "\(AppConstants.yearlyPrice)/year. Cancel anytime."
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
                }
            }

            // CTA — pinned to bottom
            VStack(spacing: DesignTokens.Spacing.md) {
                ZantButton(
                    .glass,
                    title: selectedPlan == .yearly ? "Start Free Trial" : "Subscribe",
                    isLoading: viewModel.isPurchasing
                ) {
                    purchasePlan()
                }

                ZantButton(.ghost, title: "Continue with Free") {
                    viewModel.goForward()
                }

                Text("Free includes: single focus mode, basic stats")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, DesignTokens.Spacing.xxl)
            .padding(.bottom, DesignTokens.Spacing.lg)
            .opacity(showContent ? 1 : 0)

            if let purchaseError = viewModel.purchaseError {
                Text(purchaseError)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.red.opacity(0.9))
                    .padding(.bottom, DesignTokens.Spacing.sm)
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
                .foregroundStyle(.white.opacity(0.9))

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
                        Text(plan == .yearly ? "Yearly" : "Monthly")
                            .font(DesignTokens.Typography.headline)
                            .foregroundStyle(.white)

                        if let badge {
                            Text(badge)
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(.white)
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
                    .foregroundStyle(.white)
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
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            }
        }
        .buttonStyle(.plain)
        .animation(DesignTokens.Animation.spring, value: selectedPlan)
    }

    // MARK: - Actions

    private func purchasePlan() {
        Task {
            let success = await viewModel.purchasePlan(
                isYearly: selectedPlan == .yearly,
                storeKitService: appState.storeKitService
            )
            if success {
                HapticManager.success()
                viewModel.goForward()
            } else if viewModel.purchaseError != nil {
                HapticManager.error()
            }
        }
    }
}

#Preview {
    ZStack {
        ZantMeshBackground()
        PaywallView(viewModel: OnboardingViewModel())
    }
    .environment(AppState())
}
