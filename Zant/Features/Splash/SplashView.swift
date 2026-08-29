import SwiftUI

/// Animated splash screen — Z logo scales in with glow, then transitions out.
struct SplashView: View {

    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var isFinished = false

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            // Same background as onboarding
            DesignTokens.Gradients.primaryBackground
                .ignoresSafeArea()

            // Subtle radial glow behind logo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignTokens.Colors.accent.opacity(glowOpacity),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: glowRadius)

            VStack(spacing: DesignTokens.Spacing.xl) {
                // Z Logo
                Image("AppIcon-NoBg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // App name
                Text(AppConstants.appName)
                    .font(DesignTokens.Typography.largeTitle)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            // Phase 1: Logo scales in with spring
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Phase 2: Glow pulses in
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                glowRadius = 30
                glowOpacity = 0.4
            }

            // Phase 3: Text fades in
            withAnimation(.easeIn(duration: 0.4).delay(0.6)) {
                textOpacity = 1.0
            }

            // Phase 4: Transition out
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isFinished = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onFinished()
                }
            }
        }
        .opacity(isFinished ? 0 : 1)
        .scaleEffect(isFinished ? 1.1 : 1.0)
    }
}

#Preview {
    SplashView { }
}
