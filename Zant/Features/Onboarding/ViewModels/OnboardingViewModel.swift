import SwiftUI

/// Manages all onboarding state across 6 screens.
/// Progress is persisted so app-kill mid-onboarding resumes correctly.
@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: - Navigation

    private(set) var currentStep: Int {
        didSet { UserDefaultsManager.shared.onboardingStep = currentStep }
    }

    let totalSteps = AppConstants.totalOnboardingSteps

    // MARK: - TimeScreenView

    var dailyScreenTimeHours: Double = 5.0 {
        didSet {
            let clamped = min(max(dailyScreenTimeHours, 0), Double(AppConstants.maxSliderHours))
            if dailyScreenTimeHours != clamped {
                dailyScreenTimeHours = clamped
            }
        }
    }
    var sliderInteracted: Bool = false

    // MARK: - HabitScreenView

    var selectedHabits: Set<Habit> = []
    var otherHabitText: String = "" {
        didSet {
            let trimmed = String(otherHabitText.prefix(100))
            if otherHabitText != trimmed {
                otherHabitText = trimmed
            }
        }
    }

    // MARK: - ScreenTimeConnectView

    var hasGrantedScreenTimePermission: Bool = false
    var screenTimeError: String?

    // MARK: - GemCracking

    var gemCrackTapCount: Int = 0
    var gemRevealed: Bool = false

    // MARK: - State

    var isLoading: Bool = false
    var showGemCracking: Bool = false

    // MARK: - Computed

    var yearlyHoursWasted: Double {
        dailyScreenTimeHours * 365
    }

    var yearlyDaysWasted: Double {
        yearlyHoursWasted / 24
    }

    var canProceedFromTimeScreen: Bool {
        sliderInteracted
    }

    var canProceedFromHabitScreen: Bool {
        selectedHabits.count >= AppConstants.minHabitsRequired
    }

    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    /// 3 personalized alternatives based on selected habits for CalculateTimeView.
    var personalizedAlternatives: [(icon: String, text: String)] {
        let selected = Array(selectedHabits.filter { $0 != .other }.prefix(3))
        if selected.isEmpty {
            return [
                ("book.fill", "Read 50+ books per year"),
                ("figure.run", "Build a consistent fitness routine"),
                ("brain.head.profile.fill", "Learn a new skill or language"),
            ]
        }
        return selected.map { ($0.icon, $0.timeAlternative) }
    }

    // MARK: - Init

    init() {
        self.currentStep = UserDefaultsManager.shared.onboardingStep
    }

    // MARK: - Navigation Actions

    func goBack() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func goForward() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
        HapticManager.light()
    }

    // MARK: - Habit Actions

    func toggleHabit(_ habit: Habit) {
        if selectedHabits.contains(habit) {
            selectedHabits.remove(habit)
        } else {
            selectedHabits.insert(habit)
        }
    }

    // MARK: - Screen Time Permission

    func requestScreenTimePermission() async {
        isLoading = true
        defer { isLoading = false }

        #if targetEnvironment(simulator)
        // Simulator mode - auto-approve
        try? await Task.sleep(for: .seconds(1))
        hasGrantedScreenTimePermission = true
        screenTimeError = nil
        print("📱 [Simulator] Screen Time permission auto-approved")
        #else
        do {
            print("📱 Requesting Screen Time authorization...")
            let service = ScreenTimeService.shared
            try await service.requestAuthorization()

            // Check if actually authorized
            service.checkAuthorizationStatus()
            hasGrantedScreenTimePermission = service.isAuthorized

            if hasGrantedScreenTimePermission {
                screenTimeError = nil
                print("✅ Screen Time permission granted")
            } else {
                screenTimeError = "Permission was not granted. You can enable this later in Settings."
                print("❌ Screen Time permission denied")
            }
        } catch {
            hasGrantedScreenTimePermission = false
            screenTimeError = "Could not request permission: \(error.localizedDescription)"
            print("❌ Screen Time permission error: \(error)")
        }
        #endif
    }

    // MARK: - Gem Cracking

    /// Returns a haptic intensity hint for the View layer to trigger.
    enum GemTapFeedback {
        case light
        case medium
        case heavy
        case none
    }

    func tapGem() -> GemTapFeedback {
        gemCrackTapCount += 1

        switch gemCrackTapCount {
        case 1...2:
            return .light
        case 3...4:
            return .medium
        case 5:
            Task {
                try? await Task.sleep(for: .milliseconds(200))
                gemRevealed = true
            }
            return .heavy
        default:
            return .none
        }
    }

    // MARK: - Purchase

    var isPurchasing: Bool = false
    var purchaseError: String?

    func purchasePlan(isYearly: Bool, storeKitService: any StoreKitServiceProtocol) async -> Bool {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        let productID = isYearly
            ? AppConstants.yearlyProductID
            : AppConstants.monthlyProductID

        await storeKitService.loadProducts()
        do {
            let success = try await storeKitService.purchase(productID: productID)
            if success {
                return true
            }
            // User cancelled -- stay on paywall
            return false
        } catch {
            purchaseError = "Purchase failed. Please try again."
            return false
        }
    }

    // MARK: - Completion

    func completeOnboarding(appState: AppState) async {
        // Persist onboarding data
        let defaults = UserDefaultsManager.shared
        defaults.onboardingEstimate = dailyScreenTimeHours
        defaults.selectedHabits = selectedHabits.map(\.rawValue)
        defaults.hasScreenTimePermission = hasGrantedScreenTimePermission

        // Save member since date
        if defaults.memberSinceDate == nil {
            defaults.memberSinceDate = Date()
        }

        // Award welcome cup
        await appState.gemService.earnGem(type: .stone, reason: .welcome)

        // Mark onboarded
        defaults.isOnboarded = true
        appState.isOnboarded = true
    }
}
