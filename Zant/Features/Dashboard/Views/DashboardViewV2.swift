import SwiftUI
import SwiftData

// MARK: - Dashboard View V2

struct DashboardViewV2: View {

    @Environment(AppState.self) private var appState
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @State private var recentSessions: [FocusSession] = []
    @State private var weeklyStats: WeeklyStatsDTO?
    @State private var currentStreak: Int = 0
    @State private var nextMilestone: Int = 3
    @State private var todayStats: (sessions: Int, minutes: Int) = (0, 0)
    @State private var isLoading = true
    @State private var topApps: [AppUsageInfo] = []
    @State private var earnedCrystals: [CrystalType] = []

    // Sheet states for new features
    @State private var showQuickTimer: Bool = false
    @State private var showBlockTemplates: Bool = false
    @State private var showCupsCollection: Bool = false

    var body: some View {
        ZStack {
            AmbientBackground()

            if router.selectedTab == .dashboard {
                ParticleCanvasView()
                    .opacity(0.2)
                    .ignoresSafeArea()
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.xl) {
                    // Header with greeting
                    headerSection
                        .staggeredAppear(index: 0)

                    // Cup Hero Widget - NEW FEATURE
                    CupHeroWidget(
                        currentStreak: currentStreak,
                        earnedCrystals: earnedCrystals,
                        onTap: {
                            HapticManager.medium()
                            showCupsCollection = true
                        }
                    )
                    .staggeredAppear(index: 1)

                    // Streak banner
                    StreakBannerView(
                        streakDays: currentStreak,
                        nextMilestone: nextMilestone
                    ) {
                        router.selectedTab = .rewards
                    }
                    .staggeredAppear(index: 2)

                    // Top apps card (always show)
                    TopAppsCard(apps: topApps)
                        .staggeredAppear(index: 3)

                    // Today stats
                    todayStatsSection
                        .staggeredAppear(index: 4)

                    // Quick Actions Grid - REPLACED QuickStartButtonsView with full grid
                    quickActionsGrid
                        .staggeredAppear(index: 5)

                    // Weekly chart
                    if let weeklyStats {
                        WeeklyMiniChartView(weeklyStats: weeklyStats) {
                            router.selectedTab = .rewards
                        }
                        .staggeredAppear(index: 6)
                    }

                    // Recent sessions
                    RecentSessionsCard(
                        sessions: recentSessions,
                        onViewAll: {
                            router.selectedTab = .rewards
                        }
                    )
                    .staggeredAppear(index: 7)

                    Spacer(minLength: DesignTokens.Spacing.huge)
                }
                .padding(.horizontal, DesignTokens.Spacing.xl)
                .padding(.top, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.huge)
            }

            // Floating Quick Timer Button - NEW FEATURE (only show if no active session)
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
            await loadDashboardData()
        }
        .refreshable {
            await loadDashboardData()
        }
        .onChange(of: appState.activeSessionStartedAt) { _, _ in
            Task {
                await loadDashboardData()
            }
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
            CupsCollectionView(earnedCrystals: earnedCrystals)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)

            Text("Ready to focus?")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Quick Actions Grid

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Quick Start")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                    GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                ],
                spacing: DesignTokens.Spacing.md
            ) {
                quickActionCard(
                    icon: "lightbulb.fill",
                    title: "Deep Work",
                    subtitle: "25 min focus",
                    color: DesignTokens.Colors.accentTeal
                ) {
                    handleQuickStart(duration: 25, tag: .deepWork)
                }

                quickActionCard(
                    icon: "bolt.fill",
                    title: "Quick Focus",
                    subtitle: "15 min sprint",
                    color: DesignTokens.Colors.accent
                ) {
                    handleQuickStart(duration: 15, tag: .focus)
                }

                quickActionCard(
                    icon: "square.grid.2x2.fill",
                    title: "Block Templates",
                    subtitle: "Pre-made schedules",
                    color: Color.purple
                ) {
                    showBlockTemplates = true
                }

                quickActionCard(
                    icon: "lock.shield.fill",
                    title: "Block Apps",
                    subtitle: "Instant blocking",
                    color: Color.orange
                ) {
                    router.selectedTab = .focus
                }
            }
        }
    }

    private func quickActionCard(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            HapticManager.light()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(color)

                Spacer()

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Today Stats

    private var todayStatsSection: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "checkmark.circle.fill",
                value: "\(todayStats.sessions)",
                label: "Sessions Today",
                color: DesignTokens.Colors.accent
            )

            statCard(
                icon: "clock.fill",
                value: "\(todayStats.minutes)",
                label: "Minutes Today",
                color: DesignTokens.Colors.accentTeal
            )
        }
    }

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)

            Spacer()

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }

    private func handleQuickStart(duration: Int, tag: SessionTag) {
        // Navigate to focus tab and trigger session start
        router.selectedTab = .focus
        // TODO: Pre-fill the focus view with these settings
        // This would require adding a method to AppState or FocusViewModel
    }

    private func loadDashboardData() async {
        isLoading = true

        do {
            let statsService = StatsService(modelContext: modelContext)

            // Load streak and milestone with fallback
            do {
                let stats = try await statsService.getSessionStats()
                self.currentStreak = stats.currentStreak
                self.nextMilestone = calculateNextMilestone(current: stats.currentStreak)
            } catch {
                print("⚠️ Failed to load streak stats: \(error)")
                // Fallback to safe defaults
                self.currentStreak = 0
                self.nextMilestone = 3
            }

            // Load recent sessions with error handling
            do {
                let descriptor = FetchDescriptor<FocusSession>(
                    predicate: #Predicate { $0.completed },
                    sortBy: [SortDescriptor(\.endDate, order: .reverse)]
                )
                self.recentSessions = Array(try modelContext.fetch(descriptor).prefix(3))
            } catch {
                print("⚠️ Failed to load recent sessions: \(error)")
                self.recentSessions = []
            }

            // Load weekly stats with fallback
            do {
                self.weeklyStats = try await statsService.getWeeklyStats()
            } catch {
                print("⚠️ Failed to load weekly stats: \(error)")
                self.weeklyStats = nil
            }

            // Load top apps (safe - returns empty array on failure)
            self.topApps = await AppUsageService.shared.getMostUsedApps()

            // Load today stats with fallback
            do {
                self.todayStats = try await statsService.getTodayStats()
            } catch {
                print("⚠️ Failed to load today stats: \(error)")
                self.todayStats = (sessions: 0, minutes: 0)
            }

            // Load earned crystals for Cup Hero Widget (safe - returns empty array on failure)
            let crystals = await appState.crystalService.getAllCrystals()
            self.earnedCrystals = crystals.map { $0.type }

        } catch {
            print("❌ Critical error loading dashboard data: \(error)")
            // App continues with default/empty states
        }

        isLoading = false
    }

    private func calculateNextMilestone(current: Int) -> Int {
        let milestones = [3, 7, 14, 30, 60, 100, 365]
        return milestones.first(where: { $0 > current }) ?? (current + 30)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DashboardViewV2()
    }
    .environment(AppState())
    .environment(NavigationRouter())
    .modelContainer(for: FocusSession.self, inMemory: true)
}
