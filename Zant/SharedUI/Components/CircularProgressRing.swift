import SwiftUI

// MARK: - Circular Progress Ring

/// Animated circular progress ring for timer display
struct CircularProgressRing: View {

    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let accentColor: Color

    init(
        progress: Double,
        lineWidth: CGFloat = 12,
        accentColor: Color = DesignTokens.Colors.accent
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.accentColor = accentColor
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: lineWidth
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)

            // Glow effect
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: lineWidth * 2,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 8)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            CircularProgressRing(progress: 0.25)
                .frame(width: 200, height: 200)

            CircularProgressRing(progress: 0.5)
                .frame(width: 200, height: 200)

            CircularProgressRing(progress: 0.75)
                .frame(width: 200, height: 200)
        }
    }
}
