import SwiftUI

/// Onboarding Screen 3: Vertically scrollable habit selection list.
struct HabitScreenView: View {

    @Bindable var viewModel: OnboardingViewModel

    @State private var showContent = false
    @State private var showScrollHint = true
    @FocusState private var isOtherFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Title
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("What habits would you\nlike to change?")
                    .font(DesignTokens.Typography.title2)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Select all that apply")
                    .font(DesignTokens.Typography.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.bottom, DesignTokens.Spacing.lg)
            .opacity(showContent ? 1 : 0)

            // Scrollable habit list
            ZStack(alignment: .bottom) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(Habit.allCases) { habit in
                                HabitChipView(
                                    habit: habit,
                                    isSelected: viewModel.selectedHabits.contains(habit),
                                    onTap: {
                                        HapticManager.light()
                                        viewModel.toggleHabit(habit)
                                    }
                                )
                            }

                            // "Other" text field
                            if viewModel.selectedHabits.contains(.other) {
                                TextField(
                                    "",
                                    text: $viewModel.otherHabitText,
                                    prompt: Text("Describe your habit...").foregroundStyle(.white.opacity(0.4))
                                )
                                    .focused($isOtherFieldFocused)
                                    .font(DesignTokens.Typography.body)
                                    .foregroundStyle(.white)
                                    .padding(DesignTokens.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                                            .fill(Color.white.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                                                    .stroke(DesignTokens.Colors.accent.opacity(isOtherFieldFocused ? 0.6 : 0), lineWidth: 1.5)
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                                    .accessibilityLabel("Custom habit description")
                                    .accessibilityHint("Enter your own habit to break")
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .id("otherField")
                            }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.xl)
                        .padding(.bottom, DesignTokens.Spacing.xl)
                    }
                    .scrollIndicators(.hidden)
                    .opacity(showContent ? 1 : 0)
                    .onScrollPhaseChange { _, newPhase in
                        if newPhase == .interacting {
                            withAnimation { showScrollHint = false }
                        }
                    }
                    .onChange(of: viewModel.selectedHabits) { oldValue, newValue in
                        if newValue.contains(.other) && !oldValue.contains(.other) {
                            withAnimation {
                                proxy.scrollTo("otherField", anchor: .bottom)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isOtherFieldFocused = true
                            }
                        }
                    }
                }

                // Scroll hint — fades out on first scroll
                if showScrollHint {
                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .symbolEffect(.pulse)
                        .padding(.bottom, DesignTokens.Spacing.sm)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
            }

            // Continue — pinned to bottom
            OnboardingButton(title: "Continue") {
                viewModel.goForward()
            }
            .padding(.bottom, DesignTokens.Spacing.lg)
            .opacity(viewModel.canProceedFromHabitScreen ? 1 : 0.5)
            .allowsHitTesting(viewModel.canProceedFromHabitScreen)
            .opacity(showContent ? 1 : 0)
        }
        .onFirstAppear {
            withAnimation(DesignTokens.Animation.smooth) {
                showContent = true
            }
        }
    }
}

#Preview {
    ZStack {
        ZantMeshBackground()
        HabitScreenView(viewModel: OnboardingViewModel())
    }
}
