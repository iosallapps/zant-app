import SwiftUI

// MARK: - For You Card (LiquidGlass Style)

/// Recommendation card with icon, description, schedule time, and add button
struct ForYouCard: View {
    let title: String
    let description: String
    let time: String
    let icon: String
    let bgIcon: String
    let bgColor: Color

    var body: some View {
        ZStack {
            // Very faint background imagery
            Image(systemName: bgIcon)
                .font(.system(size: 44))
                .foregroundStyle(bgColor.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(10)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundStyle(DesignTokens.Colors.accent)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(3)

                Text(time)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.35))

                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)

                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.caption2)
                    Text("Add")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(.white.opacity(0.5))
            }
            .padding(14)
        }
        .frame(width: 165, height: 195)
        .liquidGlass(shape: .card)
    }
}

#Preview {
    ZStack {
        AmbientBackground()

        HStack(spacing: 12) {
            ForYouCard(
                title: "Wind Down",
                description: "Great sleep starts\nbefore bed.",
                time: "8pm-10pm",
                icon: "moon.zzz.fill",
                bgIcon: "moon.stars.fill",
                bgColor: .indigo
            )
            ForYouCard(
                title: "Deep Sleep",
                description: "Boost your sleep's\nrestorative qualities",
                time: "10pm-6am",
                icon: "sparkles",
                bgIcon: "cloud.moon.fill",
                bgColor: .blue
            )
        }
        .padding()
    }
}
