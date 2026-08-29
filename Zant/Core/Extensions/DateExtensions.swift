import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? addingTimeInterval(86400)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Formatted as "Mon, Mar 12"
    var shortFormatted: String {
        formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    /// Formatted as "9:30 AM"
    var timeFormatted: String {
        formatted(.dateTime.hour().minute())
    }
}
