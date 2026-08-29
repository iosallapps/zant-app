import SwiftUI

/// Onboarding Screen 2: Custom slider asking daily phone usage (0 to 10+ hours).
struct TimeScreenView: View {

    @Bindable var viewModel: OnboardingViewModel

    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxxl)

                    // Lottie illustration
                    LottieView(fileName: "Time")
                        .frame(width: 220, height: 220)
                        .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.md)

                    // Title
                    Text("How much time do you spend\non your phone each day?")
                        .font(DesignTokens.Typography.title2)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxl)

                    // Hour display with +/- buttons
                    HStack(spacing: DesignTokens.Spacing.lg) {
                        // Minus button
                        Button {
                            adjustHours(by: -1)
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white.opacity(viewModel.dailyScreenTimeHours > 0 ? 0.8 : 0.3))
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.dailyScreenTimeHours <= 0)

                        // Hour display
                        VStack(spacing: DesignTokens.Spacing.xxs) {
                            Text(hourDisplayText)
                                .font(DesignTokens.Typography.counterLarge)
                                .foregroundStyle(sliderColor)
                                .contentTransition(.numericText())
                                .animation(DesignTokens.Animation.quick, value: viewModel.dailyScreenTimeHours)

                            Text("hours per day")
                                .font(DesignTokens.Typography.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(minWidth: 120)

                        // Plus button
                        Button {
                            adjustHours(by: 1)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white.opacity(viewModel.dailyScreenTimeHours < 10 ? 0.8 : 0.3))
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.dailyScreenTimeHours >= 10)
                    }
                    .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xl)

                    // Custom slider
                    CustomHourSlider(
                        value: $viewModel.dailyScreenTimeHours,
                        sliderInteracted: $viewModel.sliderInteracted,
                        color: sliderColor
                    )
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .accessibilityLabel("Daily screen time")
                    .accessibilityValue("\(Int(viewModel.dailyScreenTimeHours)) hours per day")
                    .opacity(showContent ? 1 : 0)

                    // Slider labels
                    HStack {
                        Text("0h")
                        Spacer()
                        Text("10h+")
                    }
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .padding(.top, DesignTokens.Spacing.xs)
                    .opacity(showContent ? 1 : 0)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xl)
                }
            }

            // Continue button — pinned to bottom
            OnboardingButton(title: "Continue") {
                viewModel.goForward()
            }
            .padding(.bottom, DesignTokens.Spacing.lg)
            .opacity(viewModel.canProceedFromTimeScreen ? 1 : 0.5)
            .allowsHitTesting(viewModel.canProceedFromTimeScreen)
            .opacity(showContent ? 1 : 0)
        }
        .onFirstAppear {
            withAnimation(DesignTokens.Animation.smooth) {
                showContent = true
            }
        }
    }

    // MARK: - Actions

    private func adjustHours(by delta: Double) {
        let newValue = max(0, min(AppConstants.maxSliderHours, viewModel.dailyScreenTimeHours + delta))
        guard newValue != viewModel.dailyScreenTimeHours else { return }
        viewModel.sliderInteracted = true
        viewModel.dailyScreenTimeHours = newValue
        if newValue >= AppConstants.maxSliderHours {
            HapticManager.warning()
        } else {
            HapticManager.selection()
        }
    }

    // MARK: - Computed

    private var hourDisplayText: String {
        let hours = Int(viewModel.dailyScreenTimeHours)
        if hours >= 10 { return "10+" }
        return "\(hours)"
    }

    private var sliderColor: Color {
        let hours = viewModel.dailyScreenTimeHours
        if hours < 2 { return DesignTokens.Colors.sliderGreen }
        if hours < 5 { return DesignTokens.Colors.sliderYellow }
        if hours < 8 { return DesignTokens.Colors.sliderOrange }
        return DesignTokens.Colors.sliderRed
    }
}

// MARK: - Custom Slider

private struct CustomHourSlider: View {

    @Binding var value: Double
    @Binding var sliderInteracted: Bool
    let color: Color

    @State private var isDragging = false

    private let minValue: Double = 0
    private let maxValue: Double = 10
    private let trackHeight: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let thumbX = thumbPosition(in: trackWidth)

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: trackHeight)

                // Filled track
                Capsule()
                    .fill(color)
                    .frame(width: thumbX + 16, height: trackHeight)

                // Hour markers
                HStack(spacing: 0) {
                    ForEach(0...10, id: \.self) { hour in
                        if hour > 0 {
                            Spacer()
                        }
                        Circle()
                            .fill(Double(hour) <= value
                                  ? color.opacity(0.8)
                                  : Color.white.opacity(0.2))
                            .frame(width: 4, height: 4)
                        if hour < 10 {
                            Spacer()
                        }
                    }
                }

                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: 32, height: 32)
                    .shadow(color: color.opacity(0.5), radius: isDragging ? 8 : 4)
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .position(x: thumbX, y: geometry.size.height / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { drag in
                                isDragging = true
                                sliderInteracted = true
                                let newValue = drag.location.x / trackWidth * (maxValue - minValue) + minValue
                                let snapped = round(max(minValue, min(maxValue, newValue)))
                                if snapped != value {
                                    value = snapped
                                    if snapped >= maxValue {
                                        HapticManager.warning()
                                    } else {
                                        HapticManager.selection()
                                    }
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
        }
        .frame(height: 44)
    }

    private func thumbPosition(in width: CGFloat) -> CGFloat {
        let pct = (value - minValue) / (maxValue - minValue)
        let inset: CGFloat = 16
        return inset + CGFloat(pct) * (width - 2 * inset)
    }
}

#Preview {
    ZStack {
        ZantMeshBackground()
        TimeScreenView(viewModel: OnboardingViewModel())
    }
}
