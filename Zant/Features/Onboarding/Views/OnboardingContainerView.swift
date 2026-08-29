import SwiftUI

/// Root onboarding view that manages the 6-step flow.
struct OnboardingContainerView: View {

    @State private var viewModel = OnboardingViewModel()
    @State private var showCloseButton = false
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            // Background
            ZantMeshBackground()

            VStack(spacing: 0) {
                // Progress bar (hidden on first screen and gem cracking)
                if viewModel.currentStep > 0 && !viewModel.showGemCracking {
                    OnboardingProgressBar(
                        currentStep: viewModel.currentStep,
                        totalSteps: viewModel.totalSteps
                    )
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.top, DesignTokens.Spacing.sm)
                }

                // Screen content
                Group {
                    switch viewModel.currentStep {
                    case 0:
                        StartView(viewModel: viewModel)
                    case 1:
                        TimeScreenView(viewModel: viewModel)
                    case 2:
                        HabitScreenView(viewModel: viewModel)
                    case 3:
                        CalculateTimeView(viewModel: viewModel)
                    case 4:
                        OnboardingPaywallView(viewModel: viewModel)
                    case 5:
                        ScreenTimeConnectView(viewModel: viewModel)
                    default:
                        EmptyView()
                        #if DEBUG
                            .onAppear { assertionFailure("Unexpected onboarding step: \(viewModel.currentStep)") }
                        #endif
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(DesignTokens.Animation.standard, value: viewModel.currentStep)
            }
        }
        .onChange(of: viewModel.currentStep) { _, newStep in
            // Reset and show close button with delay when reaching paywall
            if newStep == 4 {
                showCloseButton = false
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation(.easeIn(duration: 0.3)) {
                        showCloseButton = true
                    }
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // Close button overlay (only on paywall screen)
            if viewModel.currentStep == 4 && !viewModel.showGemCracking {
                Button {
                    viewModel.goForward()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .opacity(showCloseButton ? 1 : 0)
                .animation(.easeIn(duration: 0.3), value: showCloseButton)
                .padding(.top, DesignTokens.Spacing.sm)
                .padding(.trailing, DesignTokens.Spacing.xl)
            }
        }
        .overlay {
            if viewModel.showGemCracking {
                CupRevealAnimationView(viewModel: viewModel) {
                    Task {
                        await viewModel.completeOnboarding(appState: appState)
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environment(AppState())
}
