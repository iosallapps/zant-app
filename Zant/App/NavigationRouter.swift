import SwiftUI

/// Centralized navigation state for the main app.
@Observable
@MainActor
final class NavigationRouter {

    enum Tab: Int, CaseIterable {
        case dashboard = 0
        case focus = 1
        case rewards = 2  // Note: keeping case name for backwards compatibility
        case profile = 3

        var title: String {
            switch self {
            case .dashboard: "Dashboard"
            case .focus: "Focus"
            case .rewards: "Stats"
            case .profile: "Profile"
            }
        }

        var icon: String {
            switch self {
            case .dashboard: "house.fill"
            case .focus: "timer"
            case .rewards: "chart.bar.fill"
            case .profile: "person.fill"
            }
        }
    }

    var selectedTab: Tab = .dashboard
    var dashboardPath = NavigationPath()
    var focusPath = NavigationPath()
    var rewardsPath = NavigationPath()
    var profilePath = NavigationPath()

    func navigateToRoot() {
        switch selectedTab {
        case .dashboard: dashboardPath = NavigationPath()
        case .focus: focusPath = NavigationPath()
        case .rewards: rewardsPath = NavigationPath()
        case .profile: profilePath = NavigationPath()
        }
    }
}
