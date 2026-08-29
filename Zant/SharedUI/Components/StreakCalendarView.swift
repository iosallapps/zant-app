import SwiftUI

// MARK: - Streak Calendar View

struct StreakCalendarView: View {

    let activeDays: Set<Date>
    let currentStreak: Int
    let month: Date

    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    init(activeDays: Set<Date>, currentStreak: Int, month: Date = Date()) {
        self.activeDays = activeDays
        self.currentStreak = currentStreak
        self.month = month
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Month header
            monthHeader

            // Weekday labels
            weekdayLabels

            // Calendar grid
            calendarGrid
        }
        .padding(DesignTokens.Spacing.lg)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Text(monthYearString)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            if currentStreak > 0 {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 14))
                    Text("\(currentStreak)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DesignTokens.Colors.accent)
                }
            }
        }
    }

    // MARK: - Weekday Labels

    private var weekdayLabels: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    // Empty cell for padding
                    Color.clear
                        .frame(height: 36)
                }
            }
        }
    }

    // MARK: - Day Cell

    private func dayCell(for date: Date) -> some View {
        let isActive = activeDays.contains { calendar.isDate($0, inSameDayAs: date) }
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()

        return ZStack {
            // Background
            Circle()
                .fill(
                    isActive
                        ? DesignTokens.Colors.accent
                        : Color.white.opacity(0.05)
                )

            // Border for today
            if isToday {
                Circle()
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
            }

            // Day number
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isActive ? .semibold : .regular))
                .foregroundStyle(
                    isFuture
                        ? .white.opacity(0.3)
                        : isActive
                            ? .white
                            : .white.opacity(0.6)
                )
        }
        .frame(width: 36, height: 36)
        .contentShape(Circle())
        .onTapGesture {
            if !isFuture {
                selectedDate = date
            }
        }
        .scaleEffect(isActive ? 1.0 : 0.95)
    }

    // MARK: - Helper Properties

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }

    private var weekdaySymbols: [String] {
        calendar.veryShortWeekdaySymbols
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }

        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end

        // Get first day of week for the month
        var days: [Date?] = []

        // Calculate offset for first day
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7

        // Add empty cells for offset
        for _ in 0..<offset {
            days.append(nil)
        }

        // Add all days in month
        var currentDate = monthStart
        while currentDate < monthEnd {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return days
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            // With streak
            StreakCalendarView(
                activeDays: Set([
                    Date(),
                    Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                ]),
                currentStreak: 4
            )

            // No streak
            StreakCalendarView(
                activeDays: Set(),
                currentStreak: 0
            )
        }
        .padding()
    }
}
