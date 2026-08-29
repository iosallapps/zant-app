import SwiftUI

// MARK: - Completion Celebration View

/// Celebratory overlay shown when a session completes
struct CompletionCelebrationView: View {

    let duration: Int
    let tag: SessionTag
    @Binding var isPresented: Bool

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var confettiTrigger: Int = 0

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti effect
            if confettiTrigger > 0 {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            // Celebration card
            VStack(spacing: 24) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(DesignTokens.Colors.success.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(DesignTokens.Colors.success)
                }

                // Title
                VStack(spacing: 8) {
                    Text("Great Focus! 🎉")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("You completed a \(duration)-minute \(tag.rawValue) session")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Stats (optional)
                HStack(spacing: 32) {
                    StatPill(
                        icon: "flame.fill",
                        value: "+1",
                        label: "Streak",
                        color: .orange
                    )

                    StatPill(
                        icon: "clock.fill",
                        value: "\(duration)",
                        label: "Minutes",
                        color: DesignTokens.Colors.accent
                    )
                }

                // Dismiss button
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DesignTokens.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 30, y: 20)
            .padding(DesignTokens.Spacing.xxxl)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            // Trigger confetti after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confettiTrigger += 1
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            opacity = 0
            scale = 0.9
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}

// MARK: - Stat Pill

private struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundStyle(color)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        CompletionCelebrationView(
            duration: 25,
            tag: .deepWork,
            isPresented: .constant(true)
        )
    }
}
