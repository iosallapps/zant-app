import SwiftUI
import SwiftData
import UIKit

@main
struct ZantApp: App {

    @State private var appState = AppState()
    @State private var router = NavigationRouter()
    @State private var showSplash = true

    private let persistence = PersistenceController.shared

    init() {
        // Set window background to match splash — eliminates white flash before SwiftUI renders
        let bg = UIColor(red: 0.118, green: 0.106, blue: 0.294, alpha: 1) // #1E1B4B
        UIWindow.appearance().backgroundColor = bg

        // Sync Screen Time authorization status on launch
        ScreenTimeService.shared.checkAuthorizationStatus()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if appState.isOnboarded {
                        MainTabView()
                            .environment(router)
                    } else {
                        OnboardingContainerView()
                    }
                }
                .environment(appState)
                .environment(\.managedObjectContext, persistence.viewContext)
                .modelContainer(persistence.swiftDataContainer)
                .animation(DesignTokens.Animation.standard, value: appState.isOnboarded)
                .onAppear {
                    // Initialize TimerService with ModelContext
                    appState.setupTimerService(modelContext: persistence.swiftDataContainer.mainContext)
                }

                if showSplash {
                    SplashView {
                        showSplash = false
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
