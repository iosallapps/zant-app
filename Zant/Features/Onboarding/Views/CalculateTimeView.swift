import SwiftUI

/// Onboarding Screen 4: Time waste reveal with Lottie, stat cards, and motivational pivot.
struct CalculateTimeView: View {

    let viewModel: OnboardingViewModel

    @State private var revealStep = 0
    @State private var dailyCounter: Int = 0
    @State private var yearlyCounter: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: DesignTokens.Spacing.lg)

            // Phase 1: Lottie + Title
            LottieView(fileName: "Success", playOnce: true)
                .frame(width: 120, height: 120)
                .opacity(revealStep >= 1 ? 1 : 0)
                .scaleEffect(revealStep >= 1 ? 1 : 0.8)
                .offset(y: revealStep >= 1 ? 0 : 30)

            Text("Your screen time reality")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, DesignTokens.Spacing.sm)
                .opacity(revealStep >= 1 ? 1 : 0)
                .offset(y: revealStep >= 1 ? 0 : 20)

            Spacer()
                .frame(height: DesignTokens.Spacing.xxl)

            // Phase 2: Stats with premium glass cards
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Daily stat
                VStack(spacing: DesignTokens.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(dailyCounter)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignTokens.Colors.warning, Color(hex: "FF6B00")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .contentTransition(.numericText(countsDown: false))

                        Text("hrs")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundStyle(DesignTokens.Colors.warning.opacity(0.6))
                            .offset(y: 8)
                    }

                    Text("spent on your phone every day")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(revealStep >= 2 ? 1 : 0)
                .offset(y: revealStep >= 2 ? 0 : 30)

                // Yearly stat
                VStack(spacing: DesignTokens.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(yearlyCounter)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignTokens.Colors.error, Color(hex: "FF2D55")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .contentTransition(.numericText(countsDown: false))

                        Text("days")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundStyle(DesignTokens.Colors.error.opacity(0.6))
                            .offset(y: 8)
                    }

                    Text("of your life lost every year")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(revealStep >= 2 ? 1 : 0)
                .offset(y: revealStep >= 2 ? 0 : 30)
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)

            Spacer()

            // Phase 3: Alternatives with glass background
            VStack(spacing: DesignTokens.Spacing.md) {
                Text("You could instead...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, DesignTokens.Spacing.xs)

                ForEach(
                    Array(viewModel.personalizedAlternatives.prefix(2).enumerated()),
                    id: \.offset
                ) { _, alt in
                    HStack(spacing: DesignTokens.Spacing.md) {
                        // Icon with gradient background
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
                                .frame(width: 32, height: 32)

                            Image(systemName: alt.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(DesignTokens.Colors.accent)
                        }

                        Text(alt.text)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()
                    }
                    .padding(.vertical, DesignTokens.Spacing.xs)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.xxl)
            .padding(.vertical, DesignTokens.Spacing.md)
            .opacity(revealStep >= 3 ? 1 : 0)
            .offset(y: revealStep >= 3 ? 0 : 40)

            Spacer()
                .frame(height: DesignTokens.Spacing.xl)

            // Phase 4: CTA Button
            OnboardingButton(title: "Take Back My Time") {
                viewModel.goForward()
            }
            .padding(.bottom, DesignTokens.Spacing.lg)
            .opacity(revealStep >= 3 ? 1 : 0)
            .offset(y: revealStep >= 3 ? 0 : 40)
        }
        .onFirstAppear {
            startRevealSequence()
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: revealStep)
    }

    // MARK: - Animation

    private func startRevealSequence() {
        let delays: [Double] = [0.3, 1.5, 3.0]
        for (index, delay) in delays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                revealStep = index + 1
            }
        }

        let targetDaily = Int(viewModel.dailyScreenTimeHours)
        let targetYearly = Int(viewModel.yearlyDaysWasted)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            animateCounter(to: targetDaily, duration: 0.6) { dailyCounter = $0 }
            animateCounter(to: targetYearly, duration: 1.0) { yearlyCounter = $0 }
        }
    }

    private func animateCounter(to target: Int, duration: Double, update: @escaping (Int) -> Void) {
        guard target > 0 else { return }
        let steps = min(target, 30)
        let interval = duration / Double(steps)

        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {
                let progress = Double(step) / Double(steps)
                let eased = 1 - pow(1 - progress, 3)
                withAnimation(.easeOut(duration: 0.08)) {
                    update(Int(Double(target) * eased))
                }
            }
        }
    }
}

#Preview {
    ZStack {
        ZantMeshBackground()
        CalculateTimeView(viewModel: OnboardingViewModel())
    }
}
