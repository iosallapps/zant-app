import SwiftUI

/// Focus receipt showing app usage breakdown in receipt style (Opal-inspired)
struct FocusReceiptCard: View {
    let totalEarned: String
    let timeSpent: String
    let appUsages: [(name: String, time: String, value: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                Text("Could've earned")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text(totalEarned)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DesignTokens.Colors.accent)
            }

            Spacer()

            // Mini receipt
            VStack(spacing: 4) {
                Text("RECEIPT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))

                Text("— — — —")
                    .font(.caption2).opacity(0.2)

                ForEach(Array(appUsages.prefix(2).enumerated()), id: \.offset) { index, usage in
                    HStack(spacing: 4) {
                        Text(usage.name)
                            .font(.system(size: 9))
                        Spacer()
                        Text(usage.time)
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }

                if appUsages.count > 2 {
                    Text("+\(appUsages.count - 2) more")
                        .font(.system(size: 8))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .font(.caption2.monospaced())
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.05))
            )

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 0.5)

            Text("View Details")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(14)
        .frame(width: 165, height: 195)
        .glassEffect(in: .rect(cornerRadius: 20))
    }

    private func receiptRow(_ label: String, _ amount: String, sub: String) -> some View {
        VStack(spacing: 1) {
            HStack {
                Text(label)
                Spacer()
                Text(amount)
            }
            HStack {
                Text("   \(sub)")
                    .font(.system(size: 8).monospaced())
                    .opacity(0.5)
                Spacer()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        FocusReceiptCard(
            totalEarned: "65 US$",
            timeSpent: "1h 45m",
            appUsages: [
                (name: "Safari", time: "41m", value: "41,00 US$"),
                (name: "TikTok", time: "14m", value: "14,29 US$"),
                (name: "Instagram", time: "9m", value: "9,95 US$")
            ]
        )
        .padding()
    }
}
