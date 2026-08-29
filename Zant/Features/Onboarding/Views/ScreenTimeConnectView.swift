import SwiftUI

/// Onboarding Screen 6: Screen Time API permission request.
struct ScreenTimeConnectView: View {

    @Bindable var viewModel: OnboardingViewModel

    @State private var showContent = false
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxxl)

                    // Illustration
                    VStack(spacing: DesignTokens.Spacing.xxl) {
                        if showSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(DesignTokens.Colors.success)
                                .frame(width: 220, height: 220)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            LottieView(fileName: "ScreenTime")
                                .frame(width: 220, height: 220)
                        }

                        Text("Connect Screen Time")
                            .font(DesignTokens.Typography.title1)
                            .foregroundStyle(.white)

                        Text("See which apps steal your time — then block them.")
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, DesignTokens.Spacing.xxl)
                    .opacity(showContent ? 1 : 0)

                    // Feature bullets
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        bulletPoint(icon: "xmark.app", text: "Block apps during focus sessions")
                        bulletPoint(icon: "chart.bar.fill", text: "Monitor your daily screen time")
                        bulletPoint(
                            icon: "gauge.with.dots.needle.33percent",
                            text: "Set smart limits on distracting apps"
                        )
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .padding(.bottom, DesignTokens.Spacing.lg)
                    .opacity(showContent ? 1 : 0)

                    // Privacy note
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text("Your data never leaves your device.")
                            .font(DesignTokens.Typography.caption)
                    }
                    .foregroundStyle(.white.opacity(0.4))
                    .opacity(showContent ? 1 : 0)

                    // Error message
                    if let error = viewModel.screenTimeError {
                        Text(error)
                            .font(DesignTokens.Typography.footnote)
                            .foregroundStyle(DesignTokens.Colors.error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignTokens.Spacing.xxl)
                            .transition(.opacity)
                    }

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xl)
                }
            }

            // CTAs — pinned to bottom
            VStack(spacing: DesignTokens.Spacing.md) {
                OnboardingButton(
                    title: "Connect Screen Time",
                    icon: "shield.checkered",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.requestScreenTimePermission()
                        if viewModel.hasGrantedScreenTimePermission {
                            HapticManager.success()
                            withAnimation(DesignTokens.Animation.spring) {
                                showSuccess = true
                            }
                            try? await Task.sleep(for: .seconds(1))
                            viewModel.showGemCracking = true
                        } else {
                            HapticManager.error()
                        }
                    }
                }

                Button {
                    viewModel.showGemCracking = true
                } label: {
                    Text("Skip for now")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.vertical, 12)
                }

                Text("You can enable this later in Settings")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, DesignTokens.Spacing.xxl)
            .padding(.top, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.lg)
            .opacity(showContent ? 1 : 0)
        }
        .onFirstAppear {
            withAnimation(DesignTokens.Animation.smooth) {
                showContent = true
            }
        }
    }

    // MARK: - Subviews

    private func bulletPoint(icon: String, text: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(DesignTokens.Colors.accent)
                .frame(width: 24)

            Text(text)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(.white.opacity(0.85))
        }
    }
}

#Preview {
    ZStack {
        ZantMeshBackground()
        ScreenTimeConnectView(viewModel: OnboardingViewModel())
    }
}
