import SwiftUI

/// Premium business-style card component with glassmorphism
struct PremiumCard<Content: View>: View {

    let title: String
    let subtitle: String?
    let icon: String
    let accentColor: Color
    let content: Content
    let action: (() -> Void)?

    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        accentColor: Color = DesignTokens.Colors.accent,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button {
            action?()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and text
                HStack(spacing: 14) {
                    // Icon container with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accentColor.opacity(0.25),
                                        accentColor.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(accentColor)
                    }

                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)

                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }

                    Spacer()

                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                // Content
                content
            }
            .padding(20)
        }
        .buttonStyle(.plain)
        .background(
            ZStack {
                // Base glass effect
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)

                // Gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Border
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: accentColor.opacity(0.1), radius: 20, y: 10)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

// Version without content
extension PremiumCard where Content == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        accentColor: Color = DesignTokens.Colors.accent,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.action = action
        self.content = EmptyView()
    }
}

#Preview {
    ZStack {
        DesignTokens.Gradients.primaryBackground

        VStack(spacing: 20) {
            PremiumCard(
                title: "Block Apps",
                subtitle: "5 apps selected",
                icon: "app.badge.fill",
                action: {}
            )

            PremiumCard(
                title: "Focus Duration",
                subtitle: "Choose your session length",
                icon: "clock.fill",
                accentColor: .cyan
            ) {
                Text("25 minutes")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding()
    }
}
