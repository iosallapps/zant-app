import SwiftUI

// MARK: - PRO Badge View

struct ProBadgeView: View {

    let style: BadgeStyle
    let onTap: (() -> Void)?

    init(style: BadgeStyle = .default, onTap: (() -> Void)? = nil) {
        self.style = style
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) {
                    badgeContent
                }
                .buttonStyle(.plain)
            } else {
                badgeContent
            }
        }
    }

    private var badgeContent: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: style.iconSize, weight: .semibold))

            Text("PRO")
                .font(.system(size: style.fontSize, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .background(
            LinearGradient(
                colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: DesignTokens.Colors.accent.opacity(0.3), radius: 4, y: 2)
    }
}

// MARK: - Badge Style

extension ProBadgeView {
    enum BadgeStyle {
        case small
        case `default`
        case large

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .default: return 12
            case .large: return 14
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .default: return 12
            case .large: return 14
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 6
            case .default: return 8
            case .large: return 10
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 3
            case .default: return 4
            case .large: return 6
            }
        }
    }
}

// MARK: - Lock Icon View (for locked features)

struct LockIconView: View {

    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 32, height: 32)

                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            ProBadgeView(style: .small)

            ProBadgeView(style: .default)

            ProBadgeView(style: .large)

            ProBadgeView(style: .default) {
                print("PRO badge tapped")
            }

            LockIconView {
                print("Lock tapped")
            }
        }
    }
}
