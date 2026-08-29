import SwiftUI

/// Animated number counter that rolls from 0 to target value.
/// Used in CalculateTimeView for dramatic effect.
///
/// Usage:
/// ```swift
/// AnimatedCounter(target: 2190, duration: 1.5)
/// AnimatedCounter(target: 91, suffix: " days", duration: 1.5)
/// ```
struct AnimatedCounter: View {

    let target: Double
    var prefix: String = ""
    var suffix: String = ""
    var duration: Double = 1.5
    var font: Font = DesignTokens.Typography.counterLarge
    var color: Color = DesignTokens.Colors.textPrimary

    @State private var currentValue: Double = 0
    @State private var hasStarted = false

    var body: some View {
        Text("\(prefix)\(formattedValue)\(suffix)")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .onAppear {
                guard !hasStarted else { return }
                hasStarted = true
                withAnimation(.easeOut(duration: duration)) {
                    currentValue = target
                }
            }
    }

    private var formattedValue: String {
        if target == target.rounded() {
            return "\(Int(currentValue))"
        }
        return String(format: "%.1f", currentValue)
    }
}

#Preview {
    VStack(spacing: DesignTokens.Spacing.lg) {
        AnimatedCounter(target: 2190, suffix: " hours")
        AnimatedCounter(
            target: 91,
            suffix: " days",
            font: DesignTokens.Typography.counterMedium,
            color: DesignTokens.Colors.error
        )
    }
}
