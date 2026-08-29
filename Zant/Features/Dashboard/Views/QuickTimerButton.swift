import SwiftUI

/// Floating Quick Timer button - Opal-inspired
/// Fixed at bottom of dashboard for instant access
struct QuickTimerButton: View {

    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            HapticManager.medium()
            action()
        } label: {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: "timer")
                    .font(.system(size: 20, weight: .semibold))

                Text("Quick Timer")
                    .font(.headline)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DesignTokens.Spacing.xxl)
            .padding(.vertical, DesignTokens.Spacing.lg + 2)
            .background(
                ZStack {
                    // Glass effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)

                    // Gradient overlay
                    LinearGradient(
                        colors: [
                            DesignTokens.Colors.accent.opacity(0.3),
                            DesignTokens.Colors.accent.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Border
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: DesignTokens.Colors.accent.opacity(0.2), radius: 20, y: 10)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Press Events Modifier

private struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

private extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack {
            Spacer()
            QuickTimerButton {
                print("Quick Timer tapped")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
