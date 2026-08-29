import SwiftUI

// MARK: - Recent Item Row (LiquidGlass Style)

/// Recent session list item with icon, title, timestamp, and delete button
struct RecentItemRow: View {
    let title: String
    let timestamp: Date
    let onDelete: () -> Void

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundStyle(DesignTokens.Colors.accent.opacity(0.7))
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                Text(formatter.string(from: timestamp))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.2))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .liquidGlass(shape: .custom(cornerRadius: 14))
    }
}

#Preview {
    ZStack {
        AmbientBackground()

        VStack(spacing: 8) {
            RecentItemRow(
                title: "Focus Session",
                timestamp: Date(),
                onDelete: {}
            )
            RecentItemRow(
                title: "Deep Work",
                timestamp: Date().addingTimeInterval(-3600),
                onDelete: {}
            )
        }
        .padding()
    }
}
