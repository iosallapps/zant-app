import SwiftUI
import StoreKit

// MARK: - Onboarding Paywall View

/// Onboarding Screen 5: Premium paywall with beautiful design matching PaywallViewV2
struct OnboardingPaywallView: View {

    @Bindable var viewModel: OnboardingViewModel
    @State private var paywallViewModel = PaywallViewModel()
    @State private var selectedPlan: SubscriptionPlan = .annual
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Background - same as other onboarding screens
            ParticleCanvasView()
                .opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: DesignTokens.Spacing.md)

                // Header
                headerSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer()
                    .frame(height: DesignTokens.Spacing.xl)

                // Features
                featuresSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer()
                    .frame(height: DesignTokens.Spacing.xl)

                // Plan selection
                planSelectionSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Spacer()
                    .frame(height: DesignTokens.Spacing.md)

                // Trial info (moved here between plans and CTA)
                trialInfoText
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // CTA button
                ctaButton
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                // Footer
                footerSection
                    .opacity(showContent ? 1 : 0)

                Spacer()
                    .frame(height: DesignTokens.Spacing.lg)
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)

            // Loading overlay
            if paywallViewModel.isProcessing {
                loadingOverlay
            }
        }
        .task {
            await paywallViewModel.loadProducts()
            paywallViewModel.trackPaywallShown(source: .firstSessionComplete)

            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
        }
        .alert("Error", isPresented: $paywallViewModel.showError) {
            Button("OK") {}
        } message: {
            Text(paywallViewModel.errorMessage)
        }
        .onChange(of: paywallViewModel.isPurchaseSuccessful) { _, success in
            if success {
                viewModel.goForward()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.accent.opacity(0.3),
                                DesignTokens.Colors.accentTeal.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Title
            Text("Unlock Zant PRO")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

            // Subtitle
            Text("Start your 7-day free trial and unlock unlimited focus sessions")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 12) {
            featureRow(
                icon: "infinity",
                title: "Unlimited Sessions",
                description: "Focus as much as you need"
            )

            featureRow(
                icon: "chart.bar.fill",
                title: "Advanced Statistics",
                description: "Detailed insights & trends"
            )

            featureRow(
                icon: "calendar.badge.clock",
                title: "Scheduled Blocks",
                description: "Coming soon",
                badge: "Soon"
            )

            featureRow(
                icon: "sparkles",
                title: "Priority Support",
                description: "Get help when you need it"
            )
        }
        .padding(DesignTokens.Spacing.lg)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func featureRow(icon: String, title: String, description: String, badge: String? = nil) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.accent.opacity(0.2),
                                DesignTokens.Colors.accentTeal.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    if let badge {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(DesignTokens.Colors.accent.opacity(0.3))
                            .clipShape(Capsule())
                    }
                }

                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()
        }
    }

    // MARK: - Plan Selection

    private var planSelectionSection: some View {
        VStack(spacing: 12) {
            planCard(.annual)
            planCard(.monthly)
        }
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        let isSelected = selectedPlan == plan
        let product = paywallViewModel.product(for: plan)

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedPlan = plan
                HapticManager.selection()
            }
        } label: {
            HStack(spacing: 16) {
                // Radio button
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? DesignTokens.Colors.accent : Color.white.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(DesignTokens.Colors.accent)
                            .frame(width: 14, height: 14)
                    }
                }

                // Plan info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)

                        if plan == .annual {
                            Text("Save 50%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(DesignTokens.Colors.success.opacity(0.8))
                                .clipShape(Capsule())
                        }
                    }

                    if let product {
                        Text(product.displayPrice + " " + plan.priceSuffix)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                    } else {
                        Text("Loading...")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                Spacer()

                // Price per month (for annual)
                if plan == .annual, let product {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "$%.2f", product.priceValue / 12))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text("per month")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .background(
                isSelected
                    ? Color.white.opacity(0.08)
                    : Color.white.opacity(0.03)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(
                        isSelected
                            ? DesignTokens.Colors.accent
                            : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Trial Info Text

    private var trialInfoText: some View {
        Text("7 days free, then \(selectedPlan.fullPriceText). Cancel anytime.")
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.5))
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            Task {
                await paywallViewModel.purchase(plan: selectedPlan)
            }
        } label: {
            HStack(spacing: 12) {
                if paywallViewModel.isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                }

                Text("Start 7-Day Free Trial")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Main gradient background
                    LinearGradient(
                        colors: [
                            DesignTokens.Colors.accent,
                            DesignTokens.Colors.accentTeal
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    // Subtle inner highlight
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: DesignTokens.Colors.accent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .opacity(paywallViewModel.products.isEmpty ? 0.5 : 1)
        .allowsHitTesting(!paywallViewModel.products.isEmpty)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack(spacing: 0) {
            Spacer()

            Button("Terms") {
                // Open terms URL
            }
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.5))

            Spacer()

            Button("Privacy") {
                // Open privacy URL
            }
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.5))

            Spacer()

            Button {
                Task {
                    await paywallViewModel.restorePurchases()
                    if paywallViewModel.isPurchaseSuccessful {
                        viewModel.goForward()
                    }
                }
            } label: {
                Text("Restore")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
            .disabled(paywallViewModel.isProcessing)

            Spacer()
        }
        .padding(.top, DesignTokens.Spacing.md)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)

                Text("Processing...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(Color(hex: "1E293B"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        ZantMeshBackground()
        OnboardingPaywallView(viewModel: OnboardingViewModel())
    }
}
