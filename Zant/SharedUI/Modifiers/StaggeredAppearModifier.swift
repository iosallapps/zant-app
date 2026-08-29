import SwiftUI

/// Fade-in + upward slide on first appear, with a staggered delay based on index.
struct StaggeredAppearModifier: ViewModifier {

    let index: Int
    var baseDelay: Double = 0.05

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onFirstAppear {
                let delay = baseDelay * Double(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(DesignTokens.Animation.smooth) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {

    func staggeredAppear(index: Int, baseDelay: Double = 0.05) -> some View {
        modifier(StaggeredAppearModifier(index: index, baseDelay: baseDelay))
    }
}
