import SwiftUI

/// Post-onboarding cup reveal — premium mystery box experience.
/// Glowing orb that intensifies with each tap, then bursts open to reveal the cup.
struct CupCrackingView: View {

    @Bindable var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    // Orb state
    @State private var orbScale: CGFloat = 1.0
    @State private var orbGlow: Double = 0.3
    @State private var orbRingRotation: Double = 0
    @State private var innerPulse: CGFloat = 1.0
    @State private var shakeOffset: CGFloat = 0

    // Crack state — generated once per tap, stable across frames
    @State private var crackPaths: [[CGPoint]] = []

    // Reveal state
    @State private var burstScale: CGFloat = 0
    @State private var burstOpacity: Double = 0
    @State private var gemScale: CGFloat = 0
    @State private var gemOpacity: Double = 0
    @State private var showConfetti = false
    @State private var raysRotation: Double = 0
    @State private var raysOpacity: Double = 0

    // Particles
    @State private var floatingParticles: [FloatingParticle] = []
    @State private var burstParticles: [BurstParticle] = []

    private let orbSize: CGFloat = 180

    var body: some View {
        ZStack {
            DesignTokens.Gradients.primaryBackground
                .ignoresSafeArea()

            // Floating ambient particles
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    for particle in floatingParticles {
                        let elapsed = time - particle.startTime
                        let x = particle.baseX + CGFloat(sin(elapsed * particle.speed + particle.phase)) * 30
                        let y = particle.baseY + CGFloat(cos(elapsed * particle.speed * 0.7 + particle.phase)) * 20
                        let alpha = particle.alpha * (0.5 + sin(elapsed * 2 + particle.phase) * 0.5)

                        context.opacity = alpha
                        let rect = CGRect(x: x - 2, y: y - 2, width: 4, height: 4)
                        context.fill(Circle().path(in: rect), with: .color(.white))
                    }
                }
            }
            .allowsHitTesting(false)
            .opacity(viewModel.gemRevealed ? 0 : 1)

            VStack(spacing: 0) {
                Spacer()

                // Instruction
                if !viewModel.gemRevealed {
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        Text(viewModel.gemCrackTapCount == 0
                            ? "Tap the cup to reveal your reward"
                            : "Tap \(AppConstants.gemCrackTapsRequired - viewModel.gemCrackTapCount) more times!")
                            .font(DesignTokens.Typography.title3)
                            .foregroundStyle(.white.opacity(0.7))

                        // Tap progress
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(0..<AppConstants.gemCrackTapsRequired, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(i < viewModel.gemCrackTapCount
                                          ? DesignTokens.Colors.accent
                                          : Color.white.opacity(0.15))
                                    .frame(width: 24, height: 4)
                                    .animation(
                                        .spring(response: 0.3, dampingFraction: 0.6),
                                        value: viewModel.gemCrackTapCount
                                    )
                            }
                        }
                        .accessibilityLabel("Tap progress: \(viewModel.gemCrackTapCount) of \(AppConstants.gemCrackTapsRequired)")
                    }
                    .transition(.opacity)
                    .padding(.bottom, DesignTokens.Spacing.huge)
                }

                // Center — Orb / Gem area
                ZStack {
                    // Light rays (post-reveal)
                    if viewModel.gemRevealed {
                        LightRaysView(rotation: raysRotation)
                            .frame(width: 300, height: 300)
                            .opacity(raysOpacity)
                    }

                    // Burst ring
                    Circle()
                        .stroke(
                            DesignTokens.Colors.accent.opacity(0.6),
                            lineWidth: 2
                        )
                        .frame(width: orbSize * 2, height: orbSize * 2)
                        .scaleEffect(burstScale)
                        .opacity(burstOpacity)

                    // Burst particles
                    ForEach(burstParticles) { p in
                        Circle()
                            .fill(p.color)
                            .frame(width: p.size, height: p.size)
                            .offset(p.offset)
                            .opacity(p.opacity)
                            .blur(radius: 1)
                    }

                    if !viewModel.gemRevealed {
                        // Outer rotating ring
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        DesignTokens.Colors.accent.opacity(0.0),
                                        DesignTokens.Colors.accent.opacity(0.4),
                                        DesignTokens.Colors.accentLight.opacity(0.2),
                                        DesignTokens.Colors.accent.opacity(0.0),
                                    ],
                                    center: .center
                                ),
                                lineWidth: 2
                            )
                            .frame(width: orbSize + 30, height: orbSize + 30)
                            .rotationEffect(.degrees(orbRingRotation))

                        // Orb glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        DesignTokens.Colors.accent.opacity(orbGlow),
                                        DesignTokens.Colors.accent.opacity(orbGlow * 0.3),
                                        .clear,
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: orbSize * 0.9
                                )
                            )
                            .frame(width: orbSize * 2, height: orbSize * 2)

                        // Main orb
                        ZStack {
                            // Glass orb base
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.2, blue: 0.7).opacity(0.9),
                                            Color(red: 0.25, green: 0.1, blue: 0.5).opacity(0.95),
                                            Color(red: 0.15, green: 0.05, blue: 0.35),
                                        ],
                                        center: .init(x: 0.35, y: 0.3),
                                        startRadius: 0,
                                        endRadius: orbSize * 0.55
                                    )
                                )
                                .frame(width: orbSize, height: orbSize)

                            // Inner energy pulse
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            DesignTokens.Colors.accent.opacity(0.5),
                                            .clear,
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: orbSize * 0.6, height: orbSize * 0.6)
                                .scaleEffect(innerPulse)

                            // Specular highlight
                            Ellipse()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: orbSize * 0.5, height: orbSize * 0.25)
                                .offset(y: -orbSize * 0.2)
                                .blur(radius: 4)

                            // Stable crack lines
                            if !crackPaths.isEmpty {
                                StableCracksView(paths: crackPaths, size: orbSize)
                            }
                        }
                        .scaleEffect(orbScale)
                        .offset(x: shakeOffset)
                        .shadow(
                            color: DesignTokens.Colors.accent.opacity(orbGlow),
                            radius: 30
                        )
                        .accessibilityLabel("Cup to reveal")
                        .accessibilityHint("Tap \(AppConstants.gemCrackTapsRequired - viewModel.gemCrackTapCount) more times to reveal your reward")
                        .onTapGesture {
                            let feedback = viewModel.tapGem()
                            switch feedback {
                            case .light: HapticManager.light()
                            case .medium: HapticManager.medium()
                            case .heavy:
                                HapticManager.heavy()
                                // Delayed success haptic for cup reveal
                                Task {
                                    try? await Task.sleep(for: .milliseconds(200))
                                    HapticManager.success()
                                }
                            case .none: break
                            }
                            handleTap()
                        }
                    }

                    // Revealed cup
                    if viewModel.gemRevealed {
                        CupRevealView()
                            .frame(width: 110, height: 130)
                            .scaleEffect(gemScale)
                            .opacity(gemOpacity)
                            .shadow(
                                color: DesignTokens.Colors.accent.opacity(0.6),
                                radius: 20
                            )
                    }
                }
                .frame(height: 280)

                // Result text
                if viewModel.gemRevealed {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Text("Welcome Cup")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Your journey to focus starts now")
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.top, DesignTokens.Spacing.xxxl)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                // Continue button
                if viewModel.gemRevealed {
                    ZantButton(.primary, title: "Continue to Zant") {
                        onComplete()
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                    .padding(.bottom, DesignTokens.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }

            // Confetti
            if showConfetti {
                ConfettiView()
            }
        }
        .animation(DesignTokens.Animation.spring, value: viewModel.gemRevealed)
        .onAppear {
            startAmbientAnimations()
        }
    }

    // MARK: - Ambient Animations

    private func startAmbientAnimations() {
        floatingParticles = (0..<20).map { _ in
            FloatingParticle(
                baseX: CGFloat.random(in: 20...380),
                baseY: CGFloat.random(in: 100...700),
                alpha: Double.random(in: 0.1...0.4),
                speed: Double.random(in: 0.5...1.5),
                phase: Double.random(in: 0...(.pi * 2)),
                startTime: Date().timeIntervalSinceReferenceDate
            )
        }

        withAnimation(
            .linear(duration: 8)
            .repeatForever(autoreverses: false)
        ) {
            orbRingRotation = 360
        }

        withAnimation(
            .easeInOut(duration: 2)
            .repeatForever(autoreverses: true)
        ) {
            innerPulse = 1.15
        }
    }

    // MARK: - Tap Handling

    private func handleTap() {
        let tap = viewModel.gemCrackTapCount

        // Bounce + shake
        withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
            orbScale = 0.88
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
            orbScale = 1.0
        }

        // Shake effect — stronger with each tap
        let shakeIntensity: CGFloat = CGFloat(tap) * 2
        withAnimation(.spring(response: 0.05, dampingFraction: 0.2)) {
            shakeOffset = shakeIntensity
        }
        withAnimation(.spring(response: 0.05, dampingFraction: 0.2).delay(0.05)) {
            shakeOffset = -shakeIntensity
        }
        withAnimation(.spring(response: 0.05, dampingFraction: 0.2).delay(0.1)) {
            shakeOffset = shakeIntensity * 0.5
        }
        withAnimation(.spring(response: 0.1, dampingFraction: 0.5).delay(0.15)) {
            shakeOffset = 0
        }

        // Intensify glow
        withAnimation(.easeOut(duration: 0.3)) {
            orbGlow = 0.3 + Double(tap) * 0.15
        }

        // Generate cracks starting from tap 2
        if tap >= 2 {
            addCracks(for: tap)
        }

        // Final tap — explode
        if tap >= AppConstants.gemCrackTapsRequired {
            explodeAndReveal()
        }
    }

    private func addCracks(for tap: Int) {
        let center = CGPoint(x: orbSize / 2, y: orbSize / 2)
        let newCrackCount = tap <= 3 ? 3 : 5
        let maxRadius: CGFloat = orbSize * 0.35 * (CGFloat(tap) / CGFloat(AppConstants.gemCrackTapsRequired))

        for _ in 0..<newCrackCount {
            let angle = Double.random(in: 0...(2 * .pi))
            var points: [CGPoint] = [center]
            let segments = Int.random(in: 3...5)

            for s in 0..<segments {
                let progress = CGFloat(s + 1) / CGFloat(segments)
                let dist = maxRadius * progress
                let jitter = Double.random(in: -0.3...0.3)
                let next = CGPoint(
                    x: center.x + CGFloat(cos(angle + jitter)) * dist + CGFloat.random(in: -4...4),
                    y: center.y + CGFloat(sin(angle + jitter)) * dist + CGFloat.random(in: -4...4)
                )
                points.append(next)
            }

            crackPaths.append(points)
        }
    }

    private func explodeAndReveal() {
        // Burst ring
        withAnimation(.easeOut(duration: 0.5)) {
            burstScale = 1.5
            burstOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            burstOpacity = 0
        }

        // Burst particles
        burstParticles = (0..<24).map { i in
            let angle = Double(i) * (360.0 / 24.0) + Double.random(in: -10...10)
            let rad = angle * .pi / 180
            let dist = CGFloat.random(in: 100...200)
            return BurstParticle(
                offset: .zero,
                targetOffset: CGSize(
                    width: CGFloat(cos(rad)) * dist,
                    height: CGFloat(sin(rad)) * dist
                ),
                size: CGFloat.random(in: 4...10),
                color: [
                    DesignTokens.Colors.accent,
                    DesignTokens.Colors.accentLight,
                    .white,
                    .purple.opacity(0.8),
                ].randomElement() ?? DesignTokens.Colors.accent,
                opacity: 1.0
            )
        }

        withAnimation(.easeOut(duration: 0.6)) {
            burstParticles = burstParticles.map { p in
                var particle = p
                particle.offset = p.targetOffset
                particle.opacity = 0
                return particle
            }
        }

        // Flash
        withAnimation(.easeOut(duration: 0.15)) {
            orbGlow = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
            orbGlow = 0
        }

        // Reveal cup
        withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.3)) {
            gemScale = 1.0
            gemOpacity = 1.0
        }

        // Light rays
        withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
            raysOpacity = 0.4
        }
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            raysRotation = 360
        }

        // Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showConfetti = true
        }
    }
}

// MARK: - Stable Cracks (pre-computed, no per-frame randomness)

private struct StableCracksView: View {
    let paths: [[CGPoint]]
    let size: CGFloat

    var body: some View {
        Canvas { context, _ in
            for points in paths {
                guard points.count >= 2 else { continue }

                var path = Path()
                path.move(to: points[0])
                for pt in points.dropFirst() {
                    path.addLine(to: pt)
                }

                // Glow layer
                context.stroke(
                    path,
                    with: .color(Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.7)),
                    lineWidth: 3
                )
                // Core bright line
                context.stroke(
                    path,
                    with: .color(.white.opacity(0.8)),
                    lineWidth: 1.2
                )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .transition(.opacity)
    }
}

// MARK: - Light Rays

private struct LightRaysView: View {
    let rotation: Double

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let rayCount = 12

            for i in 0..<rayCount {
                let angle = (Double(i) / Double(rayCount)) * 360
                let rad = angle * .pi / 180

                var path = Path()
                path.move(to: center)

                let endX = center.x + CGFloat(cos(rad)) * size.width * 0.5
                let endY = center.y + CGFloat(sin(rad)) * size.height * 0.5

                let width: CGFloat = 8
                let perpX = CGFloat(-sin(rad)) * width
                let perpY = CGFloat(cos(rad)) * width

                path.addLine(to: CGPoint(x: endX + perpX, y: endY + perpY))
                path.addLine(to: CGPoint(x: endX - perpX, y: endY - perpY))
                path.closeSubpath()

                context.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3),
                            .clear,
                        ]),
                        startPoint: center,
                        endPoint: CGPoint(x: endX, y: endY)
                    )
                )
            }
        }
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Cup Reveal (trophy cup)

private struct CupRevealView: View {
    @State private var shimmer: CGFloat = -1

    var body: some View {
        ZStack {
            Canvas { context, size in
                let w = size.width
                let h = size.height

                // Trophy Cup Shape
                // Handles (left)
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.15, y: h * 0.25),
                    CGPoint(x: w * 0.05, y: h * 0.35),
                    CGPoint(x: w * 0.15, y: h * 0.45),
                ], color: Color(red: 0.65, green: 0.45, blue: 0.95))

                // Handles (right)
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.85, y: h * 0.25),
                    CGPoint(x: w * 0.95, y: h * 0.35),
                    CGPoint(x: w * 0.85, y: h * 0.45),
                ], color: Color(red: 0.65, green: 0.45, blue: 0.95))

                // Main bowl - left side
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.25, y: h * 0.15),
                    CGPoint(x: w * 0.35, y: h * 0.55),
                    CGPoint(x: w * 0.5, y: h * 0.55),
                    CGPoint(x: w * 0.5, y: h * 0.15),
                ], color: Color(red: 0.7, green: 0.5, blue: 1.0))

                // Main bowl - right side
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.5, y: h * 0.15),
                    CGPoint(x: w * 0.5, y: h * 0.55),
                    CGPoint(x: w * 0.65, y: h * 0.55),
                    CGPoint(x: w * 0.75, y: h * 0.15),
                ], color: Color(red: 0.75, green: 0.55, blue: 1.0))

                // Top rim
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.2, y: h * 0.1),
                    CGPoint(x: w * 0.25, y: h * 0.15),
                    CGPoint(x: w * 0.75, y: h * 0.15),
                    CGPoint(x: w * 0.8, y: h * 0.1),
                ], color: Color(red: 0.8, green: 0.6, blue: 1.0))

                // Bottom bowl section
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.35, y: h * 0.55),
                    CGPoint(x: w * 0.4, y: h * 0.65),
                    CGPoint(x: w * 0.6, y: h * 0.65),
                    CGPoint(x: w * 0.65, y: h * 0.55),
                ], color: Color(red: 0.6, green: 0.4, blue: 0.9))

                // Stem
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.45, y: h * 0.65),
                    CGPoint(x: w * 0.45, y: h * 0.85),
                    CGPoint(x: w * 0.55, y: h * 0.85),
                    CGPoint(x: w * 0.55, y: h * 0.65),
                ], color: Color(red: 0.5, green: 0.3, blue: 0.8))

                // Base
                drawFacet(&context, points: [
                    CGPoint(x: w * 0.3, y: h * 0.85),
                    CGPoint(x: w * 0.3, y: h * 0.92),
                    CGPoint(x: w * 0.7, y: h * 0.92),
                    CGPoint(x: w * 0.7, y: h * 0.85),
                ], color: Color(red: 0.55, green: 0.35, blue: 0.85))

                // Outline
                var outline = Path()
                // Left rim
                outline.move(to: CGPoint(x: w * 0.2, y: h * 0.1))
                outline.addLine(to: CGPoint(x: w * 0.25, y: h * 0.15))
                // Left handle
                outline.addLine(to: CGPoint(x: w * 0.15, y: h * 0.25))
                outline.addLine(to: CGPoint(x: w * 0.05, y: h * 0.35))
                outline.addLine(to: CGPoint(x: w * 0.15, y: h * 0.45))
                outline.addLine(to: CGPoint(x: w * 0.35, y: h * 0.55))
                // Bottom
                outline.addLine(to: CGPoint(x: w * 0.4, y: h * 0.65))
                outline.addLine(to: CGPoint(x: w * 0.45, y: h * 0.65))
                outline.addLine(to: CGPoint(x: w * 0.45, y: h * 0.85))
                outline.addLine(to: CGPoint(x: w * 0.3, y: h * 0.85))
                outline.addLine(to: CGPoint(x: w * 0.3, y: h * 0.92))
                outline.addLine(to: CGPoint(x: w * 0.7, y: h * 0.92))
                outline.addLine(to: CGPoint(x: w * 0.7, y: h * 0.85))
                outline.addLine(to: CGPoint(x: w * 0.55, y: h * 0.85))
                outline.addLine(to: CGPoint(x: w * 0.55, y: h * 0.65))
                outline.addLine(to: CGPoint(x: w * 0.6, y: h * 0.65))
                outline.addLine(to: CGPoint(x: w * 0.65, y: h * 0.55))
                // Right handle
                outline.addLine(to: CGPoint(x: w * 0.85, y: h * 0.45))
                outline.addLine(to: CGPoint(x: w * 0.95, y: h * 0.35))
                outline.addLine(to: CGPoint(x: w * 0.85, y: h * 0.25))
                outline.addLine(to: CGPoint(x: w * 0.75, y: h * 0.15))
                // Top rim
                outline.addLine(to: CGPoint(x: w * 0.8, y: h * 0.1))
                outline.closeSubpath()

                context.stroke(outline, with: .color(.white.opacity(0.3)), lineWidth: 1.5)

                // Highlights on bowl
                var highlight = Path()
                highlight.move(to: CGPoint(x: w * 0.3, y: h * 0.2))
                highlight.addLine(to: CGPoint(x: w * 0.35, y: h * 0.25))
                highlight.addLine(to: CGPoint(x: w * 0.38, y: h * 0.5))
                context.stroke(highlight, with: .color(.white.opacity(0.4)), lineWidth: 2)
            }

            // Shimmer sweep
            GeometryReader { geo in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * 0.3)
                    .offset(x: shimmer * geo.size.width)
                    .mask {
                        CupMaskShape()
                    }
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: false)
                .delay(0.8)
            ) {
                shimmer = 1.5
            }
        }
    }

    private func drawFacet(_ context: inout GraphicsContext, points: [CGPoint], color: Color) {
        var path = Path()
        path.move(to: points[0])
        for pt in points.dropFirst() { path.addLine(to: pt) }
        path.closeSubpath()
        context.fill(path, with: .color(color))
    }
}

private struct CupMaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // Trophy cup outline for mask
        path.move(to: CGPoint(x: w * 0.2, y: h * 0.1))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.05, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.85))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.85))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.92))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.92))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.85))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.85))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.1))
        path.closeSubpath()

        return path
    }
}

// MARK: - Models

private struct FloatingParticle: Identifiable {
    let id = UUID()
    let baseX: CGFloat
    let baseY: CGFloat
    let alpha: Double
    let speed: Double
    let phase: Double
    let startTime: TimeInterval
}

private struct BurstParticle: Identifiable {
    let id = UUID()
    var offset: CGSize
    var targetOffset: CGSize
    var size: CGFloat
    var color: Color
    var opacity: Double
}

#Preview {
    CupCrackingView(viewModel: OnboardingViewModel()) {}
}
