import SwiftUI

/// Places a blurred colored circle behind the content for a glow effect.
struct GlowModifier: ViewModifier {

    let color: Color
    var radius: CGFloat = 30
    var glowOpacity: Double = 0.4

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(color.opacity(glowOpacity))
                    .blur(radius: radius)
            )
    }
}

extension View {

    func glowBackground(
        color: Color,
        radius: CGFloat = 30,
        opacity: Double = 0.4
    ) -> some View {
        modifier(GlowModifier(color: color, radius: radius, glowOpacity: opacity))
    }
}
