import SwiftUI

/// Glass card with frosted material, subtle gradient border, and soft shadow.
struct GlassCardModifier: ViewModifier {

    var cornerRadius: CGFloat = DesignTokens.Radius.lg
    var padding: CGFloat = DesignTokens.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }
}

extension View {

    func glassCard(
        cornerRadius: CGFloat = DesignTokens.Radius.lg,
        padding: CGFloat = DesignTokens.Spacing.lg
    ) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
