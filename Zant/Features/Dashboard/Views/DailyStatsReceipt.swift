import SwiftUI

/// Receipt-style card showing today's focus session breakdown
struct DailyStatsReceipt: View {
    let sessions: [SessionBreakdown]
    let totalMinutes: Int
    let xpEarned: Int
    let cupsEarned: Int

    var body: some View {
        PaperReceiptCard(title: "Daily Focus Receipt") {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                // Header
                Text("Today's Focus Activity")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer().frame(height: DesignTokens.Spacing.xs)

                // Session breakdown
                if sessions.isEmpty {
                    Text("NO SESSIONS LOGGED")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, DesignTokens.Spacing.md)
                } else {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(Array(sessions.enumerated()), id: \.offset) { index, session in
                            ReceiptLineItem(
                                number: "\(index + 1)",
                                name: "Focus Session",
                                value: session.minutes,
                                subtitle: session.timestamp
                            )
                        }
                    }

                    Spacer().frame(height: DesignTokens.Spacing.sm)

                    // Subtotals
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        ReceiptTotalRow(
                            label: "Total Focus",
                            value: "\(totalMinutes) min",
                            isTotal: false
                        )

                        ReceiptTotalRow(
                            label: "XP Earned",
                            value: "+\(xpEarned)",
                            isTotal: false
                        )

                        // Separator
                        DashedLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .frame(height: 1)
                            .foregroundStyle(.white.opacity(0.2))

                        ReceiptTotalRow(
                            label: "Cups Earned",
                            value: "\(cupsEarned) 🏆",
                            isTotal: true
                        )
                    }
                }
            }
        }
    }
}

struct SessionBreakdown {
    let minutes: String
    let timestamp: String
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        DailyStatsReceipt(
            sessions: [
                SessionBreakdown(minutes: "25 min", timestamp: "09:15 AM"),
                SessionBreakdown(minutes: "45 min", timestamp: "11:30 AM"),
                SessionBreakdown(minutes: "30 min", timestamp: "02:00 PM")
            ],
            totalMinutes: 100,
            xpEarned: 200,
            cupsEarned: 3
        )
        .padding()
    }
}
