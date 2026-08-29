import SwiftUI

/// Onboarding Screen 1: Welcome screen with logo, tagline, and particle animation.
struct StartView: View {

    let viewModel: OnboardingViewModel

    @State private var showContent = false
    @State private var showFeatures = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // App name
            Text(AppConstants.appName)
                .font(DesignTokens.Typography.largeTitle)
                .foregroundStyle(.white)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

            Spacer()
                .frame(height: DesignTokens.Spacing.xs)

            // Lottie
            LottieView(fileName: "TimeTable")
                .frame(width: 240, height: 240)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.6)

            // Subtitle
            Text("Focus App")
                .font(DesignTokens.Typography.callout)
                .foregroundStyle(.white.opacity(0.5))
                .tracking(3)
                .textCase(.uppercase)
                .opacity(showContent ? 1 : 0)

            Spacer()
                .frame(height: DesignTokens.Spacing.xxxl)

            // Tagline
            Text("Take back your time.")
                .font(DesignTokens.Typography.title2)
                .foregroundStyle(.white)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)

            Spacer()
                .frame(height: DesignTokens.Spacing.xxs)

            Text("Your all-in-one digital wellness companion")
                .font(DesignTokens.Typography.subheadline)
                .foregroundStyle(.white.opacity(0.45))
                .opacity(showContent ? 1 : 0)

            Spacer()
                .frame(height: DesignTokens.Spacing.xxl)

            // Feature cards — 2x2 grid for 375pt safety
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.sm)
                ],
                spacing: DesignTokens.Spacing.sm
            ) {
                featureCard(icon: "lock.shield.fill", title: "Block Apps")
                featureCard(icon: "timer", title: "Focus Sessions")
                featureCard(icon: "flame.fill", title: "Track Streaks")
                featureCard(icon: "chart.bar.fill", title: "View Stats")
            }
            .padding(.horizontal, DesignTokens.Spacing.xxl)
            .opacity(showFeatures ? 1 : 0)
            .offset(y: showFeatures ? 0 : 25)

            Spacer()

            // CTA
            OnboardingButton(title: "Get Started") {
                viewModel.goForward()
            }
            .padding(.bottom, DesignTokens.Spacing.lg)
            .opacity(showFeatures ? 1 : 0)
            .offset(y: showFeatures ? 0 : 20)
        }
        .background {
            ParticleCanvasView()
                .opacity(0.6)
        }
        .onFirstAppear {
            withAnimation(DesignTokens.Animation.slow) {
                showContent = true
            }
            withAnimation(DesignTokens.Animation.slow.delay(0.4)) {
                showFeatures = true
            }
        }
    }

    // MARK: - Subviews

    private func featureCard(icon: String, title: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: DesignTokens.IconSize.lg))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))

            Text(title)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }
}

#Preview {
    ZStack {
        ZantMeshBackground()
        StartView(viewModel: OnboardingViewModel())
    }
}
