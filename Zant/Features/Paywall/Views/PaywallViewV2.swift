import SwiftUI
import StoreKit

// MARK: - Paywall View

struct PaywallViewV2: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PaywallViewModel()
    @State private var selectedPlan: SubscriptionPlan = .annual

    let source: PaywallSource
    let canDismiss: Bool

    init(source: PaywallSource, canDismiss: Bool = true) {
        self.source = source
        self.canDismiss = canDismiss
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "0F172A"),
                    Color(hex: "1E293B"),
                    Color(hex: "0F172A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button (if dismissible)
                if canDismiss {
                    closeButton
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                        .padding(.top, DesignTokens.Spacing.lg)
                }

                Spacer()
                    .frame(height: canDismiss ? DesignTokens.Spacing.md : DesignTokens.Spacing.xxl)

                // Header
                headerSection
                    .padding(.horizontal, DesignTokens.Spacing.xl)

                Spacer()
                    .frame(height: DesignTokens.Spacing.xl)

                // Features
                featuresSection
                    .padding(.horizontal, DesignTokens.Spacing.xl)

                Spacer()
                    .frame(height: DesignTokens.Spacing.xl)

                // Plan selection
                planSelectionSection
                    .padding(.horizontal, DesignTokens.Spacing.xl)

                Spacer()
                    .frame(height: DesignTokens.Spacing.md)

                // Trial info (moved here between plans and CTA)
                trialInfoText
                    .padding(.horizontal, DesignTokens.Spacing.xl)

                Spacer()

                // CTA button
                ctaButton
                    .padding(.horizontal, DesignTokens.Spacing.xl)

                // Restore & links
                footerSection
                    .padding(.horizontal, DesignTokens.Spacing.xl)

                Spacer()
                    .frame(height: DesignTokens.Spacing.lg)
            }

            // Loading overlay
            if viewModel.isProcessing {
                loadingOverlay
            }
        }
        .task {
            await viewModel.loadProducts()
            viewModel.trackPaywallShown(source: source)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
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
            Text(headerSubtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var headerSubtitle: String {
        switch source {
        case .sessionLimit:
            return "You've reached your daily session limit. Upgrade for unlimited focus sessions."
        case .firstSessionComplete:
            return "Great job! Unlock unlimited sessions and advanced features."
        case .settings:
            return "Supercharge your focus with unlimited sessions and insights."
        case .statsView:
            return "Get the full picture with advanced statistics and insights."
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 12) {
            featureRow(
                icon: "infinity",
                title: "Unlimited Sessions",
                description: "Focus as much as you need, no limits"
            )

            featureRow(
                icon: "chart.bar.fill",
                title: "Advanced Statistics",
                description: "Detailed insights and analytics"
            )

            featureRow(
                icon: "calendar.badge.clock",
                title: "Scheduled Blocks",
                description: "Coming soon: Recurring focus schedules",
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
        let product = viewModel.product(for: plan)

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedPlan = plan
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
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            Task {
                await viewModel.purchase(plan: selectedPlan)
                if viewModel.isPurchaseSuccessful {
                    dismiss()
                }
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                }

                Text("Start 7-Day Free Trial")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: DesignTokens.Colors.accent.opacity(0.4), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isProcessing || viewModel.products.isEmpty)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack(spacing: 16) {
            // Terms & Privacy on left
            HStack(spacing: 16) {
                Button("Terms") {
                    // Open terms URL
                }

                Text("•")
                    .foregroundStyle(.white.opacity(0.3))

                Button("Privacy") {
                    // Open privacy URL
                }
            }
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.5))

            Spacer()

            // Restore on right
            Button {
                Task {
                    await viewModel.restorePurchases()
                }
            } label: {
                Text("Restore")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
            .disabled(viewModel.isProcessing)
        }
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

// MARK: - Subscription Plan

enum SubscriptionPlan {
    case monthly
    case annual

    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        }
    }

    var priceSuffix: String {
        switch self {
        case .monthly: return "per month"
        case .annual: return "per year"
        }
    }

    var fullPriceText: String {
        switch self {
        case .monthly: return "$4.99/month"
        case .annual: return "$29.99/year"
        }
    }

    var productID: String {
        switch self {
        case .monthly: return AppConstants.monthlyProductID
        case .annual: return AppConstants.yearlyProductID
        }
    }
}

// MARK: - Paywall Source

enum PaywallSource: String {
    case sessionLimit = "session_limit"
    case firstSessionComplete = "first_session_complete"
    case settings = "settings"
    case statsView = "stats_view"
}

// MARK: - Preview

#Preview {
    PaywallViewV2(source: .firstSessionComplete)
}
