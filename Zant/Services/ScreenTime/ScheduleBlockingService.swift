import Foundation
#if !targetEnvironment(simulator)
import DeviceActivity
#endif

/// Registers DeviceActivity schedules for time-based blocking rules.
/// The DeviceActivityMonitor extension handles applying/removing shields at schedule boundaries.
final class ScheduleBlockingService: @unchecked Sendable {

    static let shared = ScheduleBlockingService()

    #if !targetEnvironment(simulator)
    private let center = DeviceActivityCenter()
    #endif

    private init() {}

    /// Register a blocking schedule. The DeviceActivityMonitor extension will apply shields.
    func registerSchedule(for rule: BlockingRuleRecord) throws {
        #if !targetEnvironment(simulator)
        let schedule = DeviceActivitySchedule(
            intervalStart: rule.startTime,
            intervalEnd: rule.endTime,
            repeats: true
        )
        let activityName = DeviceActivityName("zant.rule.\(rule.id.uuidString)")
        try center.startMonitoring(activityName, during: schedule)
        #endif
    }

    /// Register a one-shot schedule (e.g., for unbreakable session timeout).
    func registerOneShot(expiresAt: Date) throws {
        #if !targetEnvironment(simulator)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: expiresAt)
        let now = calendar.dateComponents([.hour, .minute, .second], from: .now)

        let schedule = DeviceActivitySchedule(
            intervalStart: now,
            intervalEnd: components,
            repeats: false
        )
        let activityName = DeviceActivityName("zant.session.unbreakable")
        try center.startMonitoring(activityName, during: schedule)
        #endif
    }

    func unregisterSchedule(for ruleID: UUID) {
        #if !targetEnvironment(simulator)
        let activityName = DeviceActivityName("zant.rule.\(ruleID.uuidString)")
        center.stopMonitoring([activityName])
        #endif
    }

    func unregisterUnbreakableSession() {
        #if !targetEnvironment(simulator)
        let activityName = DeviceActivityName("zant.session.unbreakable")
        center.stopMonitoring([activityName])
        #endif
    }

    func unregisterAll() {
        #if !targetEnvironment(simulator)
        center.stopMonitoring()
        #endif
    }
}
