import Foundation

// MARK: - Analytics Service Protocol

protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent)
    func setUserProperty(key: String, value: String)
}

// MARK: - Analytics Event

enum AnalyticsEvent {
    // Onboarding
    case onboardingStarted
    case onboardingCompleted
    case permissionGranted
    case permissionDenied

    // Sessions
    case sessionStarted(duration: Int, appsCount: Int, tag: String)
    case sessionCompleted
    case sessionAbandoned(remainingMinutes: Int)
    case breakTaken

    // Streaks
    case streakIncremented(newStreak: Int)
    case streakBroken(lastStreak: Int)
    case streakMilestone(days: Int)

    // Monetization
    case paywallShown(source: String)
    case trialStarted(product: String)
    case purchaseCompleted(product: String, price: Double)
    case purchaseFailed(reason: String)
    case subscriptionPurchased(plan: String)
    case subscriptionPurchaseFailed(error: String)
    case subscriptionRestored

    // Engagement
    case appOpened(sessionCount: Int, streak: Int, isPro: Bool)
    case tabViewed(tab: String)
    case featureUsed(feature: String)

    var name: String {
        switch self {
        case .onboardingStarted: return "onboarding_started"
        case .onboardingCompleted: return "onboarding_completed"
        case .permissionGranted: return "permission_granted"
        case .permissionDenied: return "permission_denied"
        case .sessionStarted: return "session_started"
        case .sessionCompleted: return "session_completed"
        case .sessionAbandoned: return "session_abandoned"
        case .breakTaken: return "break_taken"
        case .streakIncremented: return "streak_incremented"
        case .streakBroken: return "streak_broken"
        case .streakMilestone: return "streak_milestone"
        case .paywallShown: return "paywall_shown"
        case .trialStarted: return "trial_started"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        case .subscriptionPurchased: return "subscription_purchased"
        case .subscriptionPurchaseFailed: return "subscription_purchase_failed"
        case .subscriptionRestored: return "subscription_restored"
        case .appOpened: return "app_opened"
        case .tabViewed: return "tab_viewed"
        case .featureUsed: return "feature_used"
        }
    }

    var parameters: [String: String] {
        switch self {
        case .sessionStarted(let duration, let appsCount, let tag):
            return [
                "duration": "\(duration)",
                "apps_count": "\(appsCount)",
                "tag": tag
            ]
        case .sessionAbandoned(let remainingMinutes):
            return ["remaining_minutes": "\(remainingMinutes)"]
        case .streakIncremented(let newStreak):
            return ["new_streak": "\(newStreak)"]
        case .streakBroken(let lastStreak):
            return ["last_streak": "\(lastStreak)"]
        case .streakMilestone(let days):
            return ["days": "\(days)"]
        case .paywallShown(let source):
            return ["source": source]
        case .trialStarted(let product):
            return ["product": product]
        case .purchaseCompleted(let product, let price):
            return ["product": product, "price": "\(price)"]
        case .purchaseFailed(let reason):
            return ["reason": reason]
        case .subscriptionPurchased(let plan):
            return ["plan": plan]
        case .subscriptionPurchaseFailed(let error):
            return ["error": error]
        case .appOpened(let sessionCount, let streak, let isPro):
            return [
                "session_count": "\(sessionCount)",
                "streak": "\(streak)",
                "is_pro": "\(isPro)"
            ]
        case .tabViewed(let tab):
            return ["tab": tab]
        case .featureUsed(let feature):
            return ["feature": feature]
        default:
            return [:]
        }
    }
}

// MARK: - Analytics Service

final class AnalyticsService: AnalyticsServiceProtocol {

    // MARK: - Singleton

    static let shared = AnalyticsService()

    // MARK: - Properties

    private var isEnabled: Bool = true

    // MARK: - Initialization

    private init() {
        #if DEBUG
        isEnabled = false // Disable in debug builds
        #endif
    }

    // MARK: - Public Methods

    func track(_ event: AnalyticsEvent) {
        guard isEnabled else {
            print("📊 [Analytics - Debug] \(event.name) \(event.parameters)")
            return
        }

        // TODO: Integrate TelemetryDeck or other analytics provider
        // TelemetryDeck.signal(event.name, parameters: event.parameters)

        print("📊 [Analytics] \(event.name) \(event.parameters)")
    }

    func setUserProperty(key: String, value: String) {
        guard isEnabled else {
            print("📊 [Analytics - Debug] Set property: \(key) = \(value)")
            return
        }

        // TODO: Integrate TelemetryDeck
        print("📊 [Analytics] Set property: \(key) = \(value)")
    }

    // MARK: - Configuration

    func enable() {
        isEnabled = true
    }

    func disable() {
        isEnabled = false
    }
}
