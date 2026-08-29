import SwiftUI

struct DashboardView: View {

    @Environment(AppState.self) private var appState
    @Environment(NavigationRouter.self) private var router

    @State private var viewModel: DashboardViewModel?

    @State private var animatedScore: Int = 0
    @State private var animatedScreenTime: Int = 0
    @State private var animatedSessions: Int = 0

    @State private var showBlockApps: Bool = false
    @State private var showWeeklyReport: Bool = false
    @State private var showQuickTimer: Bool = false
    @State private var showBlockTemplates: Bool = false
    @State private var showCupsCollection: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AmbientBackground()

            if router.selectedTab == .dashboard {
                ParticleCanvasView()
                    .opacity(0.2)
                    .ignoresSafeArea()
            }

            if viewModel != nil {
                scrollContent
                    .overlay(alignment: .top) {
                        if viewModel?.isLoading == true {
                            ProgressView()
                                .tint(DesignTokens.Colors.textSecondary)
                                .padding(.top, DesignTokens.Spacing.xxxl)
                                .transition(.opacity)
                                .animation(DesignTokens.Animation.smooth, value: viewModel?.isLoading)
                        }
                    }
            } else {
                ProgressView()
                    .tint(DesignTokens.Colors.accent)
            }

            // Floating Quick Timer Button (only show if no active session)
            if appState.activeSessionStartedAt == nil {
                VStack {
                    Spacer()
                    QuickTimerButton {
                        showQuickTimer = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.activeSessionStartedAt)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            let vm = DashboardViewModel(appState: appState)
            await vm.loadData()
            viewModel = vm
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedScore = focusScore
                    animatedScreenTime = focusMinutesToday
                    animatedSessions = sessionsToday
                }
            }
        }
        .onChange(of: appState.activeSessionStartedAt) { _, _ in
            Task {
                await viewModel?.loadData()
                withAnimation(.easeOut(duration: 0.6)) {
                    animatedScore = focusScore
                    animatedScreenTime = focusMinutesToday
                    animatedSessions = sessionsToday
                }
            }
        }
        .sheet(isPresented: $showBlockApps) {
            AppSelectionView()
                .environment(appState)
        }
        .sheet(isPresented: $showWeeklyReport) {
            WeeklyReportSheet(
                totalFocusMinutes: viewModel?.weeklyFocusMinutes ?? 0,
                sessionsCompleted: viewModel?.weeklySessionsCompleted ?? 0,
                currentStreak: streakDays,
                focusScore: focusScore
            )
        }
        .sheet(isPresented: $showQuickTimer) {
            QuickTimerSheet()
                .environment(appState)
                .presentationDetents([.height(550)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showBlockTemplates) {
            BlockTemplatesView()
                .environment(appState)
        }
        .sheet(isPresented: $showCupsCollection) {
            CupsCollectionView(earnedCrystals: viewModel?.earnedCrystals ?? [])
        }
    }

    // MARK: - Computed from ViewModel

    private var focusScore: Int { viewModel?.focusScore ?? 0 }
    private var streakDays: Int { viewModel?.streakDays ?? 0 }
    private var focusMinutesToday: Int { viewModel?.focusMinutesToday ?? 0 }
    private var sessionsToday: Int { viewModel?.sessionsToday ?? 0 }
    private var greeting: String { viewModel?.greeting ?? "Good day" }
    private var insights: [InsightCard] { viewModel?.insights ?? [] }
    private var isCurrentlyBlocking: Bool { viewModel?.isCurrentlyBlocking ?? false }

    private var scoreColor: Color {
        viewModel?.scoreColor ?? DesignTokens.Colors.scoreRed
    }

    private var scoreMessage: String {
        viewModel?.scoreMessage ?? Strings.Dashboard.scoreImprove
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                DashboardHeaderView(greeting: greeting, streakDays: streakDays)
                    .staggeredAppear(index: 0)

                // Cup Hero Widget - Centerpiece
                CupHeroWidget(
                    currentStreak: streakDays,
                    earnedCrystals: viewModel?.earnedCrystals ?? [],
                    onTap: {
                        HapticManager.medium()
                        showCupsCollection = true
                    }
                )
                .staggeredAppear(index: 1)

                FocusScoreHeroView(
                    focusScore: focusScore,
                    animatedScore: animatedScore,
                    animatedScreenTime: animatedScreenTime,
                    animatedSessions: animatedSessions,
                    scoreColor: scoreColor,
                    scoreMessage: scoreMessage,
                    formatTime: { viewModel?.formatTime($0) ?? "\($0)m" }
                )
                .staggeredAppear(index: 2)

                // Horizontal scroll for insights and receipt
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // TODO: Replace with real distraction data from Screen Time
                        FocusReceiptCard(
                            totalEarned: "47 US$",
                            timeSpent: "64 min",
                            appUsages: [
                                (name: "Safari", time: "41 min", value: "30 US$"),
                                (name: "TikTok", time: "14 min", value: "10 US$"),
                                (name: "Instagram", time: "9 min", value: "7 US$")
                            ]
                        )

                        ForEach(insights) { insight in
                            insightCard(insight)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .staggeredAppear(index: 3)

                QuickActionsGrid(
                    onStartSession: { router.selectedTab = .focus },
                    onBlockApps: { showBlockApps = true },
                    onBlockTemplates: { showBlockTemplates = true },
                    onWeeklyReport: {
                        Task { await viewModel?.loadWeeklyData() }
                        showWeeklyReport = true
                    }
                )
                .staggeredAppear(index: 4)

                ActiveBlocksIndicator(isCurrentlyBlocking: isCurrentlyBlocking)
                    .staggeredAppear(index: 5)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, DesignTokens.Spacing.huge)
        }
    }

    private func insightCard(_ insight: InsightCard) -> some View {
        ZStack {
            // Very faint background icon
            Image(systemName: insight.icon)
                .font(.system(size: 44))
                .foregroundStyle(insight.color.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(10)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: insight.icon)
                        .foregroundStyle(insight.color)
                    Text(insight.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(insight.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(3)

                Text(insight.metric)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))

                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)

                Text("View Details")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(14)
        }
        .frame(width: 165, height: 195)
        .glassEffect(in: .rect(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .environment(AppState())
    .environment(NavigationRouter())
}
