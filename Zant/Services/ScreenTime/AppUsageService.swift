import Foundation
#if !targetEnvironment(simulator)
import FamilyControls
import DeviceActivity
import ManagedSettings
#endif

/// Service to fetch and analyze app usage statistics
@MainActor
final class AppUsageService: @unchecked Sendable {

    static let shared = AppUsageService()

    private init() {}

    #if !targetEnvironment(simulator)
    /// Get most used apps from FamilyActivityPicker selection
    /// Note: Due to Apple's privacy restrictions, we cannot directly access usage stats
    /// for apps that the user hasn't explicitly selected. This is a privacy feature.
    func getMostUsedApps() async -> [AppUsageInfo] {
        // For now, we'll return mock data as a placeholder
        // Real implementation would require DeviceActivityReport extension
        return []
    }
    #else
    /// Simulator version with mock data
    func getMostUsedApps() async -> [AppUsageInfo] {
        return [
            AppUsageInfo(name: "Instagram", icon: "photo.on.rectangle", usageMinutes: 142, category: "Social"),
            AppUsageInfo(name: "TikTok", icon: "play.rectangle.fill", usageMinutes: 98, category: "Entertainment"),
            AppUsageInfo(name: "Twitter", icon: "bubble.left.and.bubble.right", usageMinutes: 76, category: "Social"),
            AppUsageInfo(name: "YouTube", icon: "play.rectangle", usageMinutes: 65, category: "Entertainment"),
            AppUsageInfo(name: "Safari", icon: "safari", usageMinutes: 54, category: "Productivity")
        ]
    }
    #endif
}

// MARK: - Models

struct AppUsageInfo: Identifiable {
    let id = UUID()
    let name: String
    let icon: String  // SF Symbol name
    let usageMinutes: Int
    let category: String

    var usageHours: Double {
        Double(usageMinutes) / 60.0
    }

    var formattedUsage: String {
        if usageMinutes >= 60 {
            let hours = usageMinutes / 60
            let mins = usageMinutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        } else {
            return "\(usageMinutes)m"
        }
    }
}
