import SwiftUI

/// Progress dots showing onboarding completion state.
struct OnboardingProgressBar: View {

    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep
                          ? DesignTokens.Colors.accent
                          : Color.white.opacity(0.3))
                    .frame(
                        width: step == currentStep ? 10 : 6,
                        height: step == currentStep ? 10 : 6
                    )
                    .animation(DesignTokens.Animation.spring, value: currentStep)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: DesignTokens.Spacing.xxl) {
            OnboardingProgressBar(currentStep: 0, totalSteps: 6)
            OnboardingProgressBar(currentStep: 2, totalSteps: 6)
            OnboardingProgressBar(currentStep: 5, totalSteps: 6)
        }
    }
}
