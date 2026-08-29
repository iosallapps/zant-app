import SwiftUI

/// Reusable button component with consistent styling across the app.
///
/// Usage:
/// ```swift
/// ZantButton(.primary, title: "Get Started") { doSomething() }
/// ZantButton(.secondary, title: "Skip") { skip() }
/// ZantButton(.destructive, title: "Cancel") { cancel() }
/// ```
struct ZantButton: View {

    enum Style {
        case primary
        case secondary
        case destructive
        case ghost
        case glass

        var foregroundColor: Color {
            switch self {
            case .primary: .black
            case .secondary: DesignTokens.Colors.accent
            case .destructive: .white
            case .ghost: DesignTokens.Colors.textSecondary
            case .glass: .white
            }
        }

        var backgroundGradient: LinearGradient {
            switch self {
            case .primary:
                LinearGradient(
                    colors: [.white, Color(white: 0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .secondary:
                LinearGradient(
                    colors: [DesignTokens.Colors.accent.opacity(0.15), DesignTokens.Colors.accent.opacity(0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .destructive:
                LinearGradient(
                    colors: [DesignTokens.Colors.error, DesignTokens.Colors.error],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .ghost, .glass:
                LinearGradient(
                    colors: [.clear, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }

        var font: Font {
            switch self {
            case .ghost: DesignTokens.Typography.subheadline
            default: DesignTokens.Typography.headline
            }
        }
    }

    private let style: Style
    private let title: String
    private let icon: String?
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void

    init(
        _ style: Style = .primary,
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.style = style
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            guard !isLoading, !isDisabled else { return }
            HapticManager.light()
            action()
        }) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(style.foregroundColor)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(style.font)
                    }
                    Text(title)
                        .font(style.font)
                }
            }
            .frame(maxWidth: style == .ghost ? nil : .infinity)
            .padding(.vertical, style == .ghost ? DesignTokens.Spacing.sm : DesignTokens.Spacing.lg)
            .padding(.horizontal, DesignTokens.Spacing.xxl)
            .foregroundStyle(style.foregroundColor)
            .background {
                if style != .glass {
                    style.backgroundGradient
                }
            }
            .if(style == .glass) { view in
                view.glassEffect(
                    .regular.tint(DesignTokens.Colors.glassTint).interactive(),
                    in: .capsule
                )
            }
            .clipShape(style == .glass ? AnyShape(Capsule()) : AnyShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)))
            .if(style == .primary) { view in
                view.gradientBorder(cornerRadius: DesignTokens.Radius.lg, continuous: true)
            }
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    VStack(spacing: DesignTokens.Spacing.lg) {
        ZantButton(.primary, title: "Get Started") {}
        ZantButton(.secondary, title: "Skip for now") {}
        ZantButton(.primary, title: "Loading...", isLoading: true) {}
        ZantButton(.primary, title: "Disabled", isDisabled: true) {}
        ZantButton(.destructive, title: "Cancel Session") {}
        ZantButton(.ghost, title: "Continue with Free") {}
    }
    .padding()
}
