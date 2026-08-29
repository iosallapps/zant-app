import Foundation
import UserNotifications

/// Manages local notifications for reminders, streak warnings, and achievements.
final class NotificationService: NotificationServiceProtocol, @unchecked Sendable {

    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            UserDefaultsManager.shared.hasNotificationPermission = granted
            return granted
        } catch {
            return false
        }
    }

    func scheduleSessionReminder(at hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Time to Focus"
        content.body = "Ready for a focus session? Your goals are waiting."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "session_reminder",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func scheduleStreakWarning() async {
        let content = UNMutableNotificationContent()
        content.title = "Streak at Risk!"
        content.body = "Complete a focus session before midnight to keep your streak alive."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = AppConstants.streakWarningHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "streak_warning",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func cancelAll() async {
        center.removeAllPendingNotificationRequests()
    }
}
