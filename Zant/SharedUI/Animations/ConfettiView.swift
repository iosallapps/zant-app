import SwiftUI

/// Confetti burst animation. Triggered on gem reveals, session completion, level ups.
struct ConfettiView: View {

    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var isActive = false

    let colors: [Color] = [
        DesignTokens.Colors.accent,
        DesignTokens.Colors.accentLight,
        DesignTokens.Colors.success,
        DesignTokens.Colors.warning,
        DesignTokens.Colors.textPrimary,
        DesignTokens.Colors.error,
        DesignTokens.Colors.accentLight,
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                guard isActive else { return }
                let time = timeline.date.timeIntervalSinceReferenceDate

                for piece in confettiPieces {
                    let elapsed = time - piece.startTime
                    guard elapsed > 0, elapsed < 3.0 else { continue }

                    let gravity: CGFloat = 200
                    let x = size.width / 2 + piece.velocityX * CGFloat(elapsed)
                    let y = size.height / 2 + piece.velocityY * CGFloat(elapsed) + 0.5 * gravity * CGFloat(elapsed * elapsed)
                    let rotation = Angle.degrees(piece.rotationSpeed * elapsed * 360)
                    let opacity = max(0, 1.0 - elapsed / 3.0)

                    context.opacity = opacity
                    context.translateBy(x: x, y: y)
                    context.rotate(by: rotation)

                    let rect = CGRect(
                        x: -piece.size / 2,
                        y: -piece.size / 2,
                        width: piece.size,
                        height: piece.size * 0.4
                    )
                    context.fill(
                        RoundedRectangle(cornerRadius: 1).path(in: rect),
                        with: .color(piece.color)
                    )

                    context.rotate(by: -rotation)
                    context.translateBy(x: -x, y: -y)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            burst()
        }
    }

    private func burst() {
        let now = Date().timeIntervalSinceReferenceDate
        confettiPieces = (0..<60).map { _ in
            ConfettiPiece(
                velocityX: CGFloat.random(in: -200...200),
                velocityY: CGFloat.random(in: -400 ... -100),
                rotationSpeed: Double.random(in: 0.5...3.0),
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement() ?? .white,
                startTime: now + Double.random(in: 0...0.2)
            )
        }
        isActive = true
    }
}

// MARK: - Confetti Piece

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let velocityX: CGFloat
    let velocityY: CGFloat
    let rotationSpeed: Double
    let size: CGFloat
    let color: Color
    let startTime: TimeInterval
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConfettiView()
    }
}
