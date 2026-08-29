import Foundation

/// Constants shared between the main app and extensions.
/// Add this file to ALL target memberships (Zant, ZantDeviceActivityMonitor, ZantShieldConfiguration).
enum SharedBlockingConstants {
    static let appGroupIdentifier = "group.iosallapps.Zant"

    // UserDefaults keys (shared suite)
    static let selectedAppsDataKey = "zant_selectedAppsData"
    static let blockingStateKey = "zant_blockingState"
    static let blockingStrictnessKey = "zant_blockingStrictness"

    // File names in app group container
    static let selectedAppsFilename = "selected_apps.plist"
    static let blockingRulesFilename = "blocking_rules.json"

    // ManagedSettingsStore names
    static let sessionStoreName = "zant.session"
    static let scheduleStoreName = "zant.schedule"
}
