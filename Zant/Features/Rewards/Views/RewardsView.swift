import SwiftUI

struct RewardsView: View {

    @Environment(AppState.self) private var appState
    @Environment(NavigationRouter.self) private var router

    @State private var viewModel: RewardsViewModel?

    @State private var animatedXP: Int = 0
    @State private var animatedStreak: Int = 0
    @State private var flameRotation: Double = 0
    @State private var levelRingRotation: Double = 0
    @State private var hasStartedAnimations = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AmbientBackground()

            if router.selectedTab == .rewards {
                ParticleCanvasView()
                    .opacity(0.2)
                    .ignoresSafeArea()
            }

            if viewModel != nil {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.xxxl) {
                        headerSection
                            .staggeredAppear(index: 0)
                        gemCollectionSection
                            .staggeredAppear(index: 1)
                        levelAndStreakSection
                            .staggeredAppear(index: 2)
                        challengesSection
                            .staggeredAppear(index: 3)
                        Spacer(minLength: DesignTokens.Spacing.huge)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.top, DesignTokens.Spacing.lg)
                }
                .overlay(alignment: .top) {
                    if viewModel?.isLoading == true {
                        ProgressView()
                            .tint(.white.opacity(0.6))
                            .padding(.top, DesignTokens.Spacing.xxxl)
                            .transition(.opacity)
                            .animation(DesignTokens.Animation.smooth, value: viewModel?.isLoading)
                    }
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            let vm = RewardsViewModel(appState: appState)
            await vm.loadData()
            viewModel = vm

            guard !hasStartedAnimations else { return }
            hasStartedAnimations = true

            // Animate counters with a single withAnimation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.6)) {
                    animatedXP = xpProgress
                    animatedStreak = streakDays
                }
            }

            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                flameRotation = 3
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                levelRingRotation = 360
            }
        }
    }

    // MARK: - Computed from ViewModel

    private var currentLevel: Int { viewModel?.currentLevel ?? 1 }
    private var currentXP: Int { viewModel?.currentXP ?? 0 }
    private var xpToNextLevel: Int { viewModel?.xpToNextLevel ?? 100 }
    private var xpProgress: Int { viewModel?.xpProgress ?? 0 }
    private var streakDays: Int { viewModel?.streakDays ?? 0 }
    private var totalGems: Int { viewModel?.totalGems ?? 0 }
    private var crystalCollection: [(type: CrystalType, isEarned: Bool)] { viewModel?.crystalCollection ?? [] }
    private var challenges: [Challenge] { viewModel?.challenges ?? [] }
    private var levelTitle: String { viewModel?.levelTitle ?? "Novice" }
    private var nextMilestone: Int { viewModel?.nextMilestone ?? 7 }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Rewards")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "diamond.fill")
                    .foregroundStyle(DesignTokens.Colors.accent)
                Text("\(totalGems)")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassEffect(in: .capsule)
        }
    }

    // MARK: - Level & Streak

    private var levelAndStreakSection: some View {
        HStack(spacing: 12) {
            // Level card - Opal style
            ZStack {
                // Very faint background icon
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 44))
                    .foregroundStyle(DesignTokens.Colors.accent.opacity(0.08))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(10)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(DesignTokens.Colors.accent)
                        Text("Level \(currentLevel)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Text(levelTitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(2)

                    Text("\(animatedXP) / \(xpToNextLevel) XP")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))

                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 0.5)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(DesignTokens.Colors.accent)
                                .frame(width: xpToNextLevel > 0 ? geo.size.width * CGFloat(animatedXP) / CGFloat(xpToNextLevel) : 0)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, minHeight: 195)
            .glassEffect(in: .rect(cornerRadius: 20))

            // Streak card - Opal style
            ZStack {
                // Very faint background icon
                Image(systemName: "flame.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.orange.opacity(0.08))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(10)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(animatedStreak) Days")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    Text("Current streak")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Next: \(nextMilestone) days")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))

                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 0.5)

                    Text("Keep going!")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, minHeight: 195)
            .glassEffect(in: .rect(cornerRadius: 20))
        }
        .frame(height: 220)
    }

    // MARK: - Cup Collection

    private var gemCollectionSection: some View {
        VStack(spacing: 0) {
            if crystalCollection.isEmpty {
                emptyStateView(
                    icon: "trophy.fill",
                    message: "Complete your first focus session to earn trophies!"
                )
            } else {
                // Perfect Opal-style TabView carousel
                TabView {
                    ForEach(Array(crystalCollection.enumerated()), id: \.element.type) { index, item in
                        crystalCard(item.type, isEarned: item.isEarned)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 500)
            }
        }
    }

    private func crystalCard(_ crystal: CrystalType, isEarned: Bool) -> some View {
        // TODO: Fix for production - remove the forced `true` below and use actual `isEarned` parameter
        let forceShowAllCups = true // Temporary: Show all cups as earned for UI preview
        let displayAsEarned = forceShowAllCups ? true : isEarned

        return VStack(spacing: 0) {
            Spacer().frame(height: 40)

            // Cup image - bigger and cleaner
            Image(crystal.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 220)
                .saturation(displayAsEarned ? 1.0 : 0)
                .opacity(displayAsEarned ? 1 : 0.3)

            Spacer().frame(height: 32)

            // Trophy info - better hierarchy
            VStack(spacing: 6) {
                Text(crystal.displayName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(crystal.glowColor)
                    Text(crystal.tier.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(crystal.glowColor)
                }

                if !displayAsEarned {
                    Text("Focus for \(crystal.requiredSessionMinutes) minutes to unlock")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.top, 4)
                } else {
                    Text("Unlocked")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DesignTokens.Colors.success)
                        .padding(.top, 4)
                }
            }

            Spacer().frame(height: 60)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Daily Challenges

    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Daily Challenges") {
                let completed = challenges.filter(\.isCompleted).count
                Text("\(completed)/\(challenges.count)")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            if challenges.isEmpty {
                emptyStateView(
                    icon: "flag",
                    message: "No challenges available yet. Start a session to unlock daily challenges!"
                )
            } else {
                VStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(challenges) { challenge in
                        challengeRow(challenge)
                    }
                }
            }
        }
    }

    private func challengeRow(_ challenge: Challenge) -> some View {
        HStack(spacing: 12) {
            // Icon - cleaner
            Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : challengeIcon(for: challenge))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    challenge.isCompleted
                        ? DesignTokens.Colors.success
                        : .white.opacity(0.6)
                )
                .frame(width: 32, height: 32)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)

                Text(challenge.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            // XP reward
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(challenge.xpReward)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(challenge.isCompleted ? DesignTokens.Colors.success : DesignTokens.Colors.accent)
                Text("XP")
                    .font(.system(size: 8))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(14)
        .glassEffect(in: .rect(cornerRadius: 14))
    }

    private func challengeIcon(for challenge: Challenge) -> String {
        switch challenge.identifier {
        case .focusStarter: "timer"
        case .deepWorker: "hand.raised.fill"
        case .screenLimit: "moon.stars.fill"
        }
    }

    private func emptyStateView(icon: String, message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: DesignTokens.IconSize.xl, weight: .medium))
                .foregroundStyle(.white.opacity(0.3))

            Text(message)
                .font(DesignTokens.Typography.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xxl)
    }

}

// MARK: - Preview

#Preview {
    NavigationStack {
        RewardsView()
    }
    .environment(AppState())
    .environment(NavigationRouter())
}
