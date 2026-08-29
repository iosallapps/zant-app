import SwiftUI
import StoreKit
import CoreData
import os
import UIKit

@Observable
@MainActor
final class ProfileViewModel {

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.zant", category: "ProfileViewModel")

    // MARK: - State

    var totalSessions: Int = 0
    var totalFocusHours: Int = 0
    var bestStreak: Int = 0
    var currentLevel: Int = 1
    var levelTitle: String = "Novice"
    var memberSinceString: String = ""
    var earnedCrystalTypes: [CrystalType] = []
    var dailyTargetMinutes: Int = 120

    var showDeleteConfirmation: Bool = false
    var showFinalDeleteConfirmation: Bool = false
    var showDailyTargetPicker: Bool = false
    var showStrictnessPicker: Bool = false
    var showInterventionPicker: Bool = false
    var showPaywall: Bool = false
    var isRestoringPurchases: Bool = false
    var toastMessage: String?

    // Blocking settings
    var defaultBlockingStrictness: String = "normal"
    var interventionDuration: Int = 12

    // MARK: - Dependencies

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Load

    func loadData() async {
        let defaults = UserDefaultsManager.shared

        totalSessions = defaults.totalSessionsCompleted
        totalFocusHours = defaults.totalFocusMinutes / 60
        bestStreak = defaults.bestStreakLength
        currentLevel = appState.levelService.currentLevel()
        levelTitle = Level.title(for: currentLevel)
        dailyTargetMinutes = Int(defaults.dailyScreenTimeTarget * 60)

        if let date = defaults.memberSinceDate {
            memberSinceString = Strings.Profile.memberSince(date.formatted(.dateTime.month(.wide).year()))
        } else {
            memberSinceString = Strings.Profile.memberSince(Date.now.formatted(.dateTime.month(.wide).year()))
        }

        let crystals = await appState.crystalService.getAllCrystals()
        earnedCrystalTypes = Array(Set(crystals.map(\.type)))

        // Blocking settings
        defaultBlockingStrictness = defaults.defaultBlockingStrictness
        interventionDuration = defaults.interventionDuration
    }

    // MARK: - Actions

    func updateDailyTarget(_ minutes: Int) {
        dailyTargetMinutes = minutes
        UserDefaultsManager.shared.dailyScreenTimeTarget = Double(minutes) / 60.0
    }

    var formattedDailyTarget: String {
        let h = dailyTargetMinutes / 60
        let m = dailyTargetMinutes % 60
        if m == 0 { return "\(h) hours" }
        return "\(h)h \(m)m"
    }

    func formatTargetMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if m == 0 { return "\(h) hour\(h == 1 ? "" : "s")" }
        return "\(h)h \(m)m"
    }

    func toggleNotifications() async {
        if UserDefaultsManager.shared.hasNotificationPermission {
            await appState.notificationService.cancelAll()
            UserDefaultsManager.shared.hasNotificationPermission = false
            appState.hasNotificationPermission = false
        } else {
            let granted = await appState.notificationService.requestPermission()
            UserDefaultsManager.shared.hasNotificationPermission = granted
            appState.hasNotificationPermission = granted
        }
    }

    func restorePurchases() async {
        isRestoringPurchases = true
        do {
            try await appState.storeKitService.restorePurchases()
            toastMessage = Strings.Profile.purchasesRestored
        } catch {
            toastMessage = Strings.Profile.restoreFailed
        }
        isRestoringPurchases = false
    }

    func deleteAllData() async {
        // 1. Clear Core Data FIRST and verify success
        let context = PersistenceController.shared.newBackgroundContext()
        let coreDataSuccess: Bool = await context.perform {
            do {
                let sessionRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FocusSessionEntity")
                let statsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyStatsEntity")
                let batchDelete1 = NSBatchDeleteRequest(fetchRequest: sessionRequest)
                let batchDelete2 = NSBatchDeleteRequest(fetchRequest: statsRequest)
                try context.execute(batchDelete1)
                try context.execute(batchDelete2)
                try context.save()
                return true
            } catch {
                Self.logger.error("Failed to delete Core Data: \(error.localizedDescription)")
                return false
            }
        }

        guard coreDataSuccess else {
            toastMessage = "Failed to delete data. Please try again."
            return
        }

        // 2. Reset UserDefaults (only after Core Data delete succeeded)
        UserDefaultsManager.shared.resetAll()

        // 3. Return to onboarding
        appState.isOnboarded = false
    }

    // MARK: - Blocking Settings

    func updateDefaultStrictness(_ strictness: BlockingStrictness) {
        defaultBlockingStrictness = strictness.rawValue
        UserDefaultsManager.shared.defaultBlockingStrictness = strictness.rawValue
    }

    func updateInterventionDuration(_ seconds: Int) {
        interventionDuration = seconds
        UserDefaultsManager.shared.interventionDuration = seconds
    }

    // MARK: - Rate App

    func requestAppReview() {
        #if !targetEnvironment(simulator)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
        #endif
    }
}
