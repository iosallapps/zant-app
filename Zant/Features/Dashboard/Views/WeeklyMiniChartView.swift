import SwiftUI
import Charts

// MARK: - Weekly Mini Chart View

struct WeeklyMiniChartView: View {

    let weeklyStats: WeeklyStatsDTO
    let onTapViewDetails: () -> Void

    var body: some View {
        Button(action: onTapViewDetails) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Week")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Text("\(totalSessions)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(DesignTokens.Colors.accent)

                                Text("sessions")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 3, height: 3)

                            HStack(spacing: 4) {
                                Text("\(totalMinutes)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(DesignTokens.Colors.accentTeal)

                                Text("min")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }

                // Mini chart
                Chart {
                    ForEach(Array(weeklyStats.days.enumerated()), id: \.offset) { index, day in
                        BarMark(
                            x: .value("Day", weekdayAbbreviation(for: day)),
                            y: .value("Minutes", weeklyStats.minutes[index])
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(3)
                    }
                }
                .frame(height: 100)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.system(size: 11))
                    }
                }
                .chartYAxis(.hidden)
            }
            .padding(DesignTokens.Spacing.lg)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Computed Properties

    private var totalSessions: Int {
        weeklyStats.sessions.reduce(0, +)
    }

    private var totalMinutes: Int {
        weeklyStats.minutes.reduce(0, +)
    }

    // MARK: - Helpers

    private func weekdayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        WeeklyMiniChartView(
            weeklyStats: WeeklyStatsDTO(
                days: [
                    Date().addingTimeInterval(-518400),
                    Date().addingTimeInterval(-432000),
                    Date().addingTimeInterval(-345600),
                    Date().addingTimeInterval(-259200),
                    Date().addingTimeInterval(-172800),
                    Date().addingTimeInterval(-86400),
                    Date()
                ],
                minutes: [25, 45, 30, 60, 25, 50, 40],
                sessions: [1, 2, 1, 2, 1, 2, 2]
            ),
            onTapViewDetails: {}
        )
        .padding()
    }
}
