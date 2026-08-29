import SwiftUI

/// Reusable card container with consistent styling.
///
/// Usage:
/// ```swift
/// ZantCard {
///     Text("Content")
/// }
/// ZantCard(.accent) {
///     VStack { ... }
/// }
/// ```
struct ZantCard<Content: View>: View {

    enum Style {
        case standard
        case accent
        case transparent

        var backgroundColor: Color {
            switch self {
            case .standard: DesignTokens.Colors.surfaceSecondary
            case .accent: DesignTokens.Colors.accent.opacity(0.08)
            case .transparent: .clear
            }
        }

        var borderColor: Color {
            switch self {
            case .accent: DesignTokens.Colors.accent.opacity(0.2)
            default: .clear
            }
        }
    }

    private let style: Style
    private let content: Content

    init(_ style: Style = .standard, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .padding(DesignTokens.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .stroke(style.borderColor, lineWidth: 1)
            )
    }
}

#Preview {
    VStack(spacing: DesignTokens.Spacing.lg) {
        ZantCard {
            Text("Standard Card")
        }
        ZantCard(.accent) {
            Text("Accent Card")
        }
    }
    .padding()
}
