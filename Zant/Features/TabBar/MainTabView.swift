import SwiftUI

struct MainTabView: View {

    @Environment(NavigationRouter.self) private var router
    @Environment(AppState.self) private var appState

    @State private var showActiveSession = false

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab(
                NavigationRouter.Tab.dashboard.title,
                systemImage: NavigationRouter.Tab.dashboard.icon,
                value: .dashboard
            ) {
                NavigationStack(path: $router.dashboardPath) {
                    DashboardViewV2()
                }
            }

            Tab(
                NavigationRouter.Tab.focus.title,
                systemImage: NavigationRouter.Tab.focus.icon,
                value: .focus
            ) {
                NavigationStack(path: $router.focusPath) {
                    FocusViewV2()
                }
            }

            Tab(
                NavigationRouter.Tab.rewards.title,
                systemImage: NavigationRouter.Tab.rewards.icon,
                value: .rewards
            ) {
                NavigationStack(path: $router.rewardsPath) {
                    RewardsView()
                }
            }

            Tab(
                NavigationRouter.Tab.profile.title,
                systemImage: NavigationRouter.Tab.profile.icon,
                value: .profile
            ) {
                NavigationStack(path: $router.profilePath) {
                    ProfileView()
                }
            }
        }
        .tint(DesignTokens.Colors.accent)
        .safeAreaInset(edge: .bottom) {
            if appState.activeSessionStartedAt != nil {
                FloatingSessionBar(showActiveSession: $showActiveSession)
                    .padding(.bottom, DesignTokens.Spacing.xs)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .fullScreenCover(isPresented: $showActiveSession) {
            ActiveSessionViewV2()
                .environment(appState)
        }
        .animation(DesignTokens.Animation.spring, value: appState.activeSessionStartedAt != nil)
        .task {
            await appState.checkForExpiredSession()
        }
    }
}

#Preview {
    MainTabView()
        .environment(NavigationRouter())
        .environment(AppState())
}
