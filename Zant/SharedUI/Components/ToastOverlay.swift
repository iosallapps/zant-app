import SwiftUI

/// Reusable toast overlay that slides up from the bottom with an auto-dismiss timer.
/// Used across Dashboard, Profile, and Blocking screens.
struct ToastOverlay: View {

    let message: String?
    var autoDismissDelay: TimeInterval = 2.0
    var onDismiss: (() -> Void)?

    var body: some View {
        if let toast = message {
            VStack {
                Spacer()
                Text(toast)
                    .font(DesignTokens.Typography.subheadline)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.vertical, DesignTokens.Spacing.md)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, DesignTokens.Spacing.huge)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .animation(DesignTokens.Animation.standard, value: message)
        }
    }
}
