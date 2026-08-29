import SwiftUI
import StoreKit

struct ProfileView: View {

    @Environment(AppState.self) private var appState
    @Environment(NavigationRouter.self) private var router

    @State private var viewModel: ProfileViewModel?
    @State private var avatarRotation: Double = 0
    @State private var animatedSessions: Int = 0
    @State private var animatedHours: Int = 0
    @State private var animatedStreak: Int = 0
    @State private var hasStartedAnimations = false
    @State private var showCupsCollection = false

    // MARK: - Computed from ViewModel

    private var totalSessions: Int { viewModel?.totalSessions ?? 0 }
    private var totalFocusHours: Int { viewModel?.totalFocusHours ?? 0 }
    private var bestStreak: Int { viewModel?.bestStreak ?? 0 }
    private var currentLevel: Int { viewModel?.currentLevel ?? 1 }
    private var levelTitle: String { viewModel?.levelTitle ?? "Novice" }
    private var memberSinceString: String { viewModel?.memberSinceString ?? "" }
    private var earnedCrystalTypes: [CrystalType] { viewModel?.earnedCrystalTypes ?? [] }
    private var dailyTargetMinutes: Int { viewModel?.dailyTargetMinutes ?? 120 }

    var body: some View {
        mainContent
            .toolbarBackground(.hidden, for: .navigationBar)
            .task {
                let vm = ProfileViewModel(appState: appState)
                await vm.loadData()
                viewModel = vm

                guard !hasStartedAnimations else { return }
                hasStartedAnimations = true

                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    avatarRotation = 360
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        animatedSessions = totalSessions
                        animatedHours = totalFocusHours
                        animatedStreak = bestStreak
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showDailyTargetPicker ?? false },
                set: { viewModel?.showDailyTargetPicker = $0 }
            )) {
                dailyTargetPickerSheet
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showPaywall ?? false },
                set: { viewModel?.showPaywall = $0 }
            )) {
                SettingsPaywallSheet()
                    .environment(appState)
            }
            .sheet(isPresented: $showCupsCollection) {
                CupsCollectionView(earnedCrystals: earnedCrystalTypes)
            }
            .confirmationDialog(Strings.Profile.deleteConfirmTitle, isPresented: Binding(
                get: { viewModel?.showDeleteConfirmation ?? false },
                set: { viewModel?.showDeleteConfirmation = $0 }
            )) {
                Button(Strings.Profile.deleteEverything, role: .destructive) {
                    viewModel?.showFinalDeleteConfirmation = true
                }
                Button(Strings.General.cancel, role: .cancel) {}
            } message: {
                Text(Strings.Profile.deleteConfirmMessage)
            }
            .alert(Strings.Profile.finalDeleteTitle, isPresented: Binding(
                get: { viewModel?.showFinalDeleteConfirmation ?? false },
                set: { viewModel?.showFinalDeleteConfirmation = $0 }
            )) {
                Button(Strings.Profile.yesDeleteEverything, role: .destructive) {
                    Task { await viewModel?.deleteAllData() }
                }
                Button(Strings.General.cancel, role: .cancel) {}
            } message: {
                Text(Strings.Profile.finalDeleteMessage)
            }
            .onChange(of: viewModel?.toastMessage) { _, msg in
                if msg != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewModel?.toastMessage = nil
                    }
                }
            }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ZStack {
            ZantMeshBackground()

            if router.selectedTab == .profile {
                ParticleCanvasView()
                    .opacity(0.2)
                    .ignoresSafeArea()
            }

            if viewModel != nil {
                scrollContent
            } else {
                ProgressView()
                    .tint(.white)
            }

            ToastOverlay(message: viewModel?.toastMessage)
        }
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignTokens.Spacing.xxxl) {
                ProfileCrystalPreview(earnedCrystals: earnedCrystalTypes) {
                    showCupsCollection = true
                }
                .staggeredAppear(index: 0)

                ProfileHeaderView(
                    currentLevel: currentLevel,
                    levelTitle: levelTitle,
                    memberSinceString: memberSinceString,
                    avatarRotation: $avatarRotation
                )
                .staggeredAppear(index: 1)

                ProfileStatsRow(
                    animatedSessions: animatedSessions,
                    animatedHours: animatedHours,
                    animatedStreak: animatedStreak
                )
                .staggeredAppear(index: 2)

                GeneralSettingsSection(
                    formattedDailyTarget: viewModel?.formattedDailyTarget ?? "2 hours",
                    hasNotificationPermission: appState.hasNotificationPermission,
                    onDailyTarget: { viewModel?.showDailyTargetPicker = true },
                    onNotifications: { Task { await viewModel?.toggleNotifications() } }
                )
                .staggeredAppear(index: 4)

                BlockingSettingsSection(
                    defaultStrictness: viewModel?.defaultBlockingStrictness ?? "normal",
                    interventionDuration: viewModel?.interventionDuration ?? 12,
                    onUpdateStrictness: { viewModel?.updateDefaultStrictness($0) },
                    onUpdateInterventionDuration: { viewModel?.updateInterventionDuration($0) }
                )
                .staggeredAppear(index: 5)

                SubscriptionSection(
                    isPremium: appState.isPremium,
                    isRestoringPurchases: Binding(
                        get: { viewModel?.isRestoringPurchases ?? false },
                        set: { viewModel?.isRestoringPurchases = $0 }
                    ),
                    onUpgrade: { viewModel?.showPaywall = true },
                    onRestore: { Task { await viewModel?.restorePurchases() } }
                )
                .staggeredAppear(index: 6)

                AboutSection(
                    onRateApp: { viewModel?.requestAppReview() }
                )
                .staggeredAppear(index: 7)

                DangerZoneSection(
                    onDeleteAllData: { viewModel?.showDeleteConfirmation = true }
                )
                .staggeredAppear(index: 8)

                Spacer(minLength: DesignTokens.Spacing.huge)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.lg)
        }
    }

    // MARK: - Daily Target Picker Sheet

    private var dailyTargetPickerSheet: some View {
        NavigationStack {
            List {
                ForEach([30, 60, 90, 120, 150, 180, 240], id: \.self) { minutes in
                    Button {
                        viewModel?.updateDailyTarget(minutes)
                        viewModel?.showDailyTargetPicker = false
                    } label: {
                        HStack {
                            Text(viewModel?.formatTargetMinutes(minutes) ?? "")
                                .foregroundStyle(.primary)
                            Spacer()
                            if minutes == dailyTargetMinutes {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(DesignTokens.Colors.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Strings.Profile.dailyTargetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.General.done) {
                        viewModel?.showDailyTargetPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(AppState())
    .environment(NavigationRouter())
    .preferredColorScheme(.dark)
}
