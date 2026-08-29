import SwiftUI

// MARK: - Session Gradient Background

/// Animated gradient background for active sessions
struct SessionGradientBackground: View {

    let tag: SessionTag
    let animated: Bool

    @State private var animationOffset: CGFloat = 0

    init(tag: SessionTag, animated: Bool = true) {
        self.tag = tag
        self.animated = animated
    }

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated overlay
            if animated {
                animatedOverlay
            }
        }
    }

    private var gradientColors: [Color] {
        tag.gradient.map { Color(hex: $0) }
    }

    private var animatedOverlay: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .offset(y: animationOffset)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .linear(duration: 3.0)
                .repeatForever(autoreverses: true)
            ) {
                animationOffset = 100
            }
        }
    }
}

// MARK: - Preview

#Preview("Deep Work") {
    SessionGradientBackground(tag: .deepWork)
}

#Preview("Study") {
    SessionGradientBackground(tag: .study)
}

#Preview("Focus") {
    SessionGradientBackground(tag: .focus)
}
