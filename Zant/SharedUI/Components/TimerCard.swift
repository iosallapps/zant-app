import SwiftUI

// MARK: - Timer Card (LiquidGlass Style)

/// Focus timer preset card with background icon, duration, and start button
struct TimerCard: View {
    let title: String
    let duration: String
    let bgIcon: String
    let bgColor: Color
    let onStart: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Very faint background icon
            Image(systemName: bgIcon)
                .font(.system(size: 48))
                .foregroundStyle(bgColor.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(12)

            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(duration)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Button(action: onStart) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                        Text("Start")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.white)
                }
                .padding(.top, 2)
            }
            .padding(14)
        }
        .frame(width: 155, height: 130)
        .liquidGlass(shape: .card)
    }
}

#Preview {
    ZStack {
        AmbientBackground()

        HStack(spacing: 12) {
            TimerCard(
                title: "Get it done",
                duration: "20m",
                bgIcon: "bolt.ring.closed",
                bgColor: DesignTokens.Colors.accentTeal,
                onStart: {}
            )
            TimerCard(
                title: "Work Sprint",
                duration: "25m",
                bgIcon: "desktopcomputer",
                bgColor: .blue,
                onStart: {}
            )
        }
        .padding()
    }
}
