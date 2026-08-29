import SwiftUI

/// Animated gradient border — supports one-shot draw, static, or continuous rotation.
struct GradientBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = DesignTokens.Radius.lg
    var colors: [Color] = [.red, .orange, .purple, .pink, .red]
    var lineWidth: CGFloat = 2.5
    var animated: Bool = true
    var continuous: Bool = false

    @State private var trim: CGFloat = 0
    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        if continuous {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            AngularGradient(
                                colors: colors,
                                center: .center,
                                startAngle: .degrees(rotation),
                                endAngle: .degrees(rotation + 360)
                            ),
                            lineWidth: lineWidth
                        )
                )
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        } else {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .trim(from: 0, to: trim)
                        .stroke(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: lineWidth
                        )
                )
                .onAppear {
                    if animated {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            trim = 1.0
                        }
                    } else {
                        trim = 1.0
                    }
                }
        }
    }
}

extension View {
    func gradientBorder(
        cornerRadius: CGFloat = DesignTokens.Radius.lg,
        colors: [Color] = [.red, .orange, .purple, .pink, .red],
        lineWidth: CGFloat = 2.5,
        animated: Bool = true,
        continuous: Bool = false
    ) -> some View {
        modifier(GradientBorderModifier(
            cornerRadius: cornerRadius,
            colors: colors,
            lineWidth: lineWidth,
            animated: animated,
            continuous: continuous
        ))
    }
}
