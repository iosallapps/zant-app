import SwiftUI

// MARK: - Liquid Glass Modifier (iOS 26+)

/// Compatibility wrapper for iOS 26's `.glassEffect()` modifier
extension View {

    /// Apply Liquid Glass effect with specified style and shape
    /// - Parameters:
    ///   - style: The glass style (.regular or .clear)
    ///   - shape: The shape to apply glass effect in (.card or .capsule)
    ///   - isInteractive: Whether the glass should respond to touches (scale, shimmer)
    func liquidGlass(
        style: LiquidGlassStyle = .regular,
        shape: LiquidGlassShape = .card,
        isInteractive: Bool = false
    ) -> some View {
        if #available(iOS 26.0, *) {
            let glass: Glass = isInteractive ? .regular.interactive() : .regular
            switch shape {
            case .card:
                return AnyView(self.glassEffect(glass, in: .rect(cornerRadius: DesignTokens.Radius.card)))
            case .capsule:
                return AnyView(self.glassEffect(glass, in: .capsule))
            case .custom(let radius):
                return AnyView(self.glassEffect(glass, in: .rect(cornerRadius: radius)))
            }
        } else {
            // Fallback (should never hit with iOS 26.0 target, but safety first)
            return AnyView(self.modifier(GlassCardModifier()))
        }
    }
}

enum LiquidGlassStyle {
    case regular
    case clear
}

enum LiquidGlassShape {
    case card
    case capsule
    case custom(cornerRadius: CGFloat)
}
