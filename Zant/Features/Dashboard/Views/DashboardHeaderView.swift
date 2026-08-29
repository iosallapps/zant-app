import SwiftUI

/// Dashboard header with greeting text and streak counter pill.
struct DashboardHeaderView: View {

    let greeting: String
    let streakDays: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text(Strings.Dashboard.stayFocused)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.yellow)
                Text("\(streakDays)")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassEffect(in: .capsule)
        }
        .padding(.top, DesignTokens.Spacing.xs)
    }
}
