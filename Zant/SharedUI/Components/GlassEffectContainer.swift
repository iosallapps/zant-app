import SwiftUI

// MARK: - Glass Effect Container (iOS 26+)

/// Container that combines multiple Liquid Glass shapes into a single layer
/// enabling morphing animations between shapes
@available(iOS 26.0, *)
struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: spacing) {
            content
        }
    }
}
