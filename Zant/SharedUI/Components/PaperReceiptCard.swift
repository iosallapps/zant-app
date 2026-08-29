import SwiftUI

/// Paper receipt-style card mimicking a real receipt with texture
struct PaperReceiptCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Receipt header
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.5))

            // Dashed separator line (like receipt paper)
            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .frame(height: 1)
                .foregroundStyle(.white.opacity(0.2))

            // Content
            content

            // Bottom dashed line
            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .frame(height: 1)
                .foregroundStyle(.white.opacity(0.2))

            // Receipt footer
            HStack {
                Spacer()
                Text("Time of printing: \(Date.now.formatted(.dateTime.hour().minute()))")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(
            ZStack {
                // Paper texture effect
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .fill(Color.white.opacity(0.05))

                // Subtle grain texture
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.03),
                                .white.opacity(0.01),
                                .white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Border
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            }
        )
    }
}

/// Dashed line shape for receipt separator
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

/// Receipt line item
struct ReceiptLineItem: View {
    let number: String
    let name: String
    let value: String
    let subtitle: String?

    init(number: String, name: String, value: String, subtitle: String? = nil) {
        self.number = number
        self.name = name
        self.value = value
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            // Number
            Text(number)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 20, alignment: .leading)

            // Name and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            Spacer()

            // Value
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }
}

/// Receipt subtotal/total row
struct ReceiptTotalRow: View {
    let label: String
    let value: String
    let isTotal: Bool

    init(label: String, value: String, isTotal: Bool = false) {
        self.label = label
        self.value = value
        self.isTotal = isTotal
    }

    var body: some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: isTotal ? 13 : 11, weight: isTotal ? .bold : .semibold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(.white.opacity(isTotal ? 0.9 : 0.5))

            Spacer()

            Text(value)
                .font(.system(size: isTotal ? 15 : 13, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }
}
