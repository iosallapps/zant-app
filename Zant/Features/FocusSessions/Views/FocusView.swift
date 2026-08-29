import SwiftUI

struct FocusView: View {

    // MARK: - State

    @Environment(AppState.self) private var appState
    @Environment(NavigationRouter.self) private var router

    @State private var viewModel: FocusViewModel?
    @State private var ringRotation: Double = 0
    @State private var innerPulse: Bool = false
    @State private var buttonPulse: Bool = false
    @State private var hasStartedAnimations = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AmbientBackground()

            if router.selectedTab == .focus {
                ParticleCanvasView()
                    .opacity(0.2)
                    .ignoresSafeArea()
            }

            if viewModel != nil {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.section) {
                        headerSection
                            .staggeredAppear(index: 0)
                        timerRingSection
                            .staggeredAppear(index: 1)
                        durationPresetsSection
                            .staggeredAppear(index: 2)
                        modeSelectorSection
                            .staggeredAppear(index: 3)
                        tagSelectorSection
                            .staggeredAppear(index: 4)
                        startButtonSection
                            .staggeredAppear(index: 5)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.bottom, DesignTokens.Spacing.huge)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            viewModel = FocusViewModel(appState: appState)
        }
        .onAppear {
            guard !hasStartedAnimations else { return }
            hasStartedAnimations = true
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                innerPulse = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                buttonPulse = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Text("Focus Session")
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, DesignTokens.Spacing.sm)
    }

    // MARK: - Timer Ring

    private var timerRingSection: some View {
        let ringSize: CGFloat = 220
        let lineWidth: CGFloat = 10

        return ZStack {
            // Simple clean ring
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
                .frame(width: ringSize, height: ringSize)

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    DesignTokens.Colors.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))

            // Center label - clean
            VStack(spacing: 6) {
                Text(viewModel?.formattedDuration ?? "25:00")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(DesignTokens.Animation.standard, value: viewModel?.selectedDuration)

                Text("minutes")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.vertical, 40)
    }

    // MARK: - Duration Presets

    private var durationPresetsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Duration")

            ScrollView(.horizontal, showsIndicators: false) {
                GlassEffectContainer(spacing: DesignTokens.Spacing.sm) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(viewModel?.durations ?? [], id: \.self) { duration in
                            let isSelected = duration == viewModel?.selectedDuration
                            Button {
                                HapticManager.selection()
                                withAnimation(DesignTokens.Animation.spring) {
                                    viewModel?.selectedDuration = duration
                                }
                            } label: {
                                Text("\(duration)m")
                                    .font(DesignTokens.Typography.subheadline)
                                    .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                                    .padding(.horizontal, DesignTokens.Spacing.lg)
                                    .padding(.vertical, DesignTokens.Spacing.sm)
                                    .glassEffect(
                                        isSelected
                                            ? .regular.tint(DesignTokens.Colors.accent).interactive()
                                            : .regular,
                                        in: .capsule
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Mode Selector

    private var modeSelectorSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Mode")

            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(FocusMode.allCases, id: \.rawValue) { mode in
                    modeCard(mode)
                }
            }
        }
    }

    private func modeCard(_ mode: FocusMode) -> some View {
        let isSelected = mode == viewModel?.selectedMode

        return Button {
            HapticManager.selection()
            withAnimation(DesignTokens.Animation.spring) {
                viewModel?.selectedMode = mode
            }
        } label: {
            VStack(spacing: 8) {
                Spacer()

                Image(systemName: mode.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(isSelected ? DesignTokens.Colors.accent : .white.opacity(0.7))

                Text(mode.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(mode.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)

                if mode.isPremium {
                    HStack(spacing: 3) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                        Text("PRO")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(DesignTokens.Colors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(DesignTokens.Colors.accent.opacity(0.15))
                    .clipShape(Capsule())
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .glassEffect(
                isSelected ? .regular.tint(DesignTokens.Colors.accent) : .regular,
                in: .rect(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tag Selector

    private var tagSelectorSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Tag")

            ScrollView(.horizontal, showsIndicators: false) {
                GlassEffectContainer(spacing: DesignTokens.Spacing.sm) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(SessionTag.allCases, id: \.rawValue) { tag in
                            let isSelected = tag == viewModel?.selectedTag
                            Button {
                                HapticManager.selection()
                                withAnimation(DesignTokens.Animation.spring) {
                                    viewModel?.selectedTag = tag
                                }
                            } label: {
                                HStack(spacing: DesignTokens.Spacing.xs) {
                                    Image(systemName: tag.icon)
                                        .font(.system(size: DesignTokens.IconSize.xs))
                                    Text(tag.rawValue)
                                        .font(DesignTokens.Typography.subheadline)
                                }
                                .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                                .padding(.horizontal, DesignTokens.Spacing.lg)
                                .padding(.vertical, DesignTokens.Spacing.sm)
                                .glassEffect(
                                    isSelected
                                        ? .regular.tint(DesignTokens.Colors.accent).interactive()
                                        : .regular,
                                    in: .capsule
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Start Button

    private var startButtonSection: some View {
        ZantButton(.glass, title: "Start Session", icon: "play.fill") {
            HapticManager.success()
            viewModel?.startSession()
        }
        .scaleEffect(buttonPulse ? 1.02 : 1.0)
        .padding(.top, DesignTokens.Spacing.sm)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FocusView()
    }
    .environment(AppState())
    .environment(NavigationRouter())
}
