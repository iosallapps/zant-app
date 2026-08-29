import SwiftUI

/// Post-onboarding cup reveal — premium gift box experience.
/// Gift box that shakes and opens with each tap, revealing the trophy cup inside.
struct CupRevealAnimationView: View {

    @Bindable var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    // Box state
    @State private var boxGlow: Double = 0.3

    // Lid opening state
    @State private var lidRotation: Double = 0
    @State private var lidOffset: CGFloat = 0
    @State private var lidOpacity: Double = 1.0

    // Reveal state
    @State private var burstScale: CGFloat = 0
    @State private var burstOpacity: Double = 0
    @State private var cupScale: CGFloat = 0
    @State private var cupOpacity: Double = 0
    @State private var cupRise: CGFloat = 0
    @State private var cupFloat: CGFloat = 0
    @State private var cupRotation: Double = 0
    @State private var cupPulse: CGFloat = 1.0
    @State private var showConfetti = false
    @State private var raysRotation: Double = 0
    @State private var raysOpacity: Double = 0

    // Particles
    @State private var floatingParticles: [FloatingParticle] = []
    @State private var burstParticles: [BurstParticle] = []

    private let boxSize: CGFloat = 220

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
                            ? "Tap the box to open it"
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

                // Center — Box / Cup area
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
                        .frame(width: boxSize * 2, height: boxSize * 2)
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
                        GiftBoxView(
                            boxSize: boxSize,
                            lidRotation: lidRotation,
                            lidOffset: lidOffset,
                            tapCount: viewModel.gemCrackTapCount
                        )
                        .shadow(
                            color: DesignTokens.Colors.accent.opacity(boxGlow),
                            radius: 30
                        )
                        .accessibilityLabel("Gift box to reveal")
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

                    // Revealed cup with premium animations
                    if viewModel.gemRevealed {
                        ZStack {
                            // Glow rings behind cup
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                DesignTokens.Colors.accent.opacity(0.6 - Double(i) * 0.2),
                                                DesignTokens.Colors.accentTeal.opacity(0.4 - Double(i) * 0.15),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 240 + CGFloat(i) * 30, height: 240 + CGFloat(i) * 30)
                                    .scaleEffect(cupScale * cupPulse)
                                    .opacity(cupOpacity * (0.8 - Double(i) * 0.2))
                                    .rotationEffect(.degrees(cupRotation + Double(i) * 120))
                            }

                            // The cup itself
                            Image("Crystal01")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 260, height: 260)
                                .scaleEffect(cupScale * cupPulse)
                                .opacity(cupOpacity)
                                .rotationEffect(.degrees(cupRotation), anchor: .center)
                                .shadow(
                                    color: DesignTokens.Colors.accent.opacity(0.8),
                                    radius: 40,
                                    y: 10
                                )
                                .shadow(
                                    color: DesignTokens.Colors.accentTeal.opacity(0.6),
                                    radius: 50,
                                    y: 15
                                )
                                .shadow(
                                    color: Color.white.opacity(0.5),
                                    radius: 30
                                )
                        }
                        .offset(y: cupRise + cupFloat)
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

    }

    // MARK: - Tap Handling

    private func handleTap() {
        let tap = viewModel.gemCrackTapCount

        // Intensify glow
        withAnimation(.easeOut(duration: 0.3)) {
            boxGlow = 0.3 + Double(tap) * 0.15
        }

        // Gradually open lid
        let progress = Double(tap) / Double(AppConstants.gemCrackTapsRequired)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            lidRotation = -20 * progress
            lidOffset = -10 * CGFloat(progress)
        }

        // Final tap — explode and reveal
        if tap >= AppConstants.gemCrackTapsRequired {
            explodeAndReveal()
        }
    }

    private func explodeAndReveal() {
        // Lid flies open
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            lidRotation = -120
            lidOffset = -150
        }

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
            boxGlow = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
            boxGlow = 0
        }

        // Lid flies away
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            lidRotation = -180
            lidOffset = -200
            lidOpacity = 0
        }

        // Reveal cup - dramatic entrance with bounce
        withAnimation(.spring(response: 0.9, dampingFraction: 0.55).delay(0.15)) {
            cupScale = 1.2
            cupOpacity = 1.0
            cupRise = -30
        }

        // Settle to normal size
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
            cupScale = 1.0
            cupRise = -20
        }

        // Continuous slow rotation
        withAnimation(
            .linear(duration: 8)
            .repeatForever(autoreverses: false)
            .delay(0.8)
        ) {
            cupRotation = 360
        }

        // Floating animation - gentle up/down motion
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
            .delay(1.2)
        ) {
            cupFloat = -12
        }

        // Pulse animation - subtle breathing effect
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
            .delay(1.2)
        ) {
            cupPulse = 1.05
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

// MARK: - Gift Box View

private struct GiftBoxView: View {
    let boxSize: CGFloat
    let lidRotation: Double
    let lidOffset: CGFloat
    let tapCount: Int

    @State private var shakeOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Energy particles emanating from box
                if tapCount > 0 {
                    energyParticlesOverlay
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }

                // The gift box with shake animation
                giftBoxAnimation
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .offset(x: shakeOffset)
                    .rotationEffect(.degrees(rotationAngle))
                    .onChange(of: tapCount) { oldValue, newValue in
                        if newValue > oldValue {
                            triggerShake()
                        }
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(height: boxSize * 2.5 * 1.5)  // Ensure enough space for the gift box
    }

    private var giftBoxAnimation: some View {
        let boxWidth = boxSize * 2.5  // Much bigger gift box
        let scaleValue = 1.0 + (CGFloat(tapCount) * 0.03)  // Grows bigger with each tap
        let blackShadow = Color.black.opacity(0.3)
        let accentShadow = DesignTokens.Colors.accent.opacity(0.5)
        let shouldPlayAnimation = tapCount >= AppConstants.gemCrackTapsRequired

        return LottieView(
            fileName: "Gift Box White",
            playOnce: true,
            shouldPlay: shouldPlayAnimation,
            initialFrame: 0
        )
        .frame(width: boxWidth, height: boxWidth)
        .scaleEffect(scaleValue)
        .shadow(color: blackShadow, radius: 20, y: 10)
        .shadow(color: accentShadow, radius: 30)
    }

    private var energyParticlesOverlay: some View {
        ForEach(0..<12, id: \.self) { i in
            energyParticle(at: i)
        }
    }

    private func energyParticle(at index: Int) -> some View {
        let angle = Double(index) * (.pi * 2 / 12)
        let baseDistance = boxSize * 1.2
        let tapProgress = Double(tapCount) / Double(AppConstants.gemCrackTapsRequired)
        let distance = baseDistance * CGFloat(0.5 + tapProgress * 0.5)

        let particleTypes = ["diamond.fill", "hexagon.fill", "triangle.fill", "rhombus.fill"]
        let particleSize = CGFloat(18 + (index % 4) * 4)

        return Image(systemName: particleTypes[index % 4])
            .font(.system(size: particleSize, weight: .bold))
            .foregroundStyle(particleGradient(index: index))
            .offset(
                x: CGFloat(cos(angle)) * distance,
                y: CGFloat(sin(angle)) * distance
            )
            .opacity(0.4 + 0.4 * tapProgress)
            .scaleEffect(0.6 + 0.6 * tapProgress)
            .rotationEffect(.degrees(Double(tapCount * 20 + index * 30)))
            .blur(radius: 1)
            .shadow(color: DesignTokens.Colors.accent.opacity(0.6), radius: 8)
    }

    private func particleGradient(index: Int) -> LinearGradient {
        let colors: [[Color]] = [
            [DesignTokens.Colors.accent, DesignTokens.Colors.accentLight],
            [DesignTokens.Colors.accentTeal, Color.cyan],
            [Color.white, DesignTokens.Colors.accent],
            [DesignTokens.Colors.accentLight, Color.purple.opacity(0.8)]
        ]

        return LinearGradient(
            colors: colors[index % 4],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func triggerShake() {
        let intensity = CGFloat(min(tapCount, 10)) * 1.5

        // Shake animation
        withAnimation(.easeInOut(duration: 0.05)) {
            shakeOffset = intensity
            rotationAngle = Double(tapCount % 2 == 0 ? 3 : -3)
        }
        withAnimation(.easeInOut(duration: 0.05).delay(0.05)) {
            shakeOffset = -intensity
            rotationAngle = Double(tapCount % 2 == 0 ? -3 : 3)
        }
        withAnimation(.easeInOut(duration: 0.05).delay(0.1)) {
            shakeOffset = intensity * 0.5
            rotationAngle = Double(tapCount % 2 == 0 ? 2 : -2)
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.15)) {
            shakeOffset = 0
            rotationAngle = 0
        }
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
    CupRevealAnimationView(viewModel: OnboardingViewModel()) {}
}
