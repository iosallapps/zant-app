import SwiftUI

/// Floating particle animation for the StartView background.
/// Built with Canvas + TimelineView for 60fps SwiftUI-native animation.
struct ParticleCanvasView: View {

    @State private var particles: [Particle] = (0..<30).map { _ in Particle.random() }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for particle in particles {
                    let x = particle.x * size.width
                    let baseY = particle.y * size.height
                    let y = baseY + sin(time * particle.speed + particle.phase) * 20

                    let opacity = particle.opacity * (0.5 + 0.5 * sin(time * 0.5 + particle.phase))

                    context.opacity = opacity
                    context.fill(
                        Circle().path(in: CGRect(
                            x: x - particle.size / 2,
                            y: y - particle.size / 2,
                            width: particle.size,
                            height: particle.size
                        )),
                        with: .color(.white)
                    )
                }
            }
        }
    }
}

// MARK: - Particle

private struct Particle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let speed: Double
    let phase: Double

    static func random() -> Particle {
        Particle(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 2...6),
            opacity: Double.random(in: 0.2...0.6),
            speed: Double.random(in: 0.3...1.5),
            phase: Double.random(in: 0...(2 * .pi))
        )
    }
}

#Preview {
    ZStack {
        DesignTokens.Gradients.primaryBackground.ignoresSafeArea()
        ParticleCanvasView()
    }
}
