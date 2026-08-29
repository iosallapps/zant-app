import SwiftUI

// MARK: - Quick Start Preset

struct QuickStartPreset {
    let duration: Int
    let tag: SessionTag
    let icon: String
    let title: String
    let subtitle: String
}

// MARK: - Quick Start Buttons View

struct QuickStartButtonsView: View {

    let onStartSession: (Int, SessionTag) -> Void

    private let presets: [QuickStartPreset] = [
        QuickStartPreset(
            duration: 25,
            tag: .deepWork,
            icon: "brain.head.profile",
            title: "Deep Work",
            subtitle: "25 min focus"
        ),
        QuickStartPreset(
            duration: 15,
            tag: .focus,
            icon: "bolt.fill",
            title: "Quick Focus",
            subtitle: "15 min sprint"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Quick Start")

            HStack(spacing: 12) {
                ForEach(Array(presets.enumerated()), id: \.offset) { index, preset in
                    quickStartButton(preset)
                }
            }
        }
    }

    // MARK: - Quick Start Button

    private func quickStartButton(_ preset: QuickStartPreset) -> some View {
        Button {
            onStartSession(preset.duration, preset.tag)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: preset.tag.gradient.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .opacity(0.2)
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: preset.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: preset.tag.gradient.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Spacer()

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(preset.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        QuickStartButtonsView { duration, tag in
            print("Starting \(tag.rawValue) session for \(duration) minutes")
        }
        .padding()
    }
}
