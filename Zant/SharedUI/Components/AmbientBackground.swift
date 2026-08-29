import SwiftUI

// MARK: - Ambient Background (LiquidGlass Style)

/// Black background with subtle colored ambient blobs that create depth
/// behind Liquid Glass elements. Blobs are heavily blurred and low opacity.
struct AmbientBackground: View {

    var body: some View {
        ZStack {
            // Pure black base
            Color.black.ignoresSafeArea()

            // Teal blob - top left area
            Circle()
                .fill(DesignTokens.Colors.accentTeal.opacity(0.15))
                .frame(width: 350, height: 350)
                .blur(radius: 150)
                .offset(x: -50, y: -300)

            // Green blob - middle right
            Circle()
                .fill(Color.green.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 130)
                .offset(x: 120, y: 200)

            // Cyan blob - bottom left
            Circle()
                .fill(Color.cyan.opacity(0.06))
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .offset(x: -100, y: 500)
        }
    }
}

#Preview {
    AmbientBackground()
}
