import SwiftUI

// MARK: - Duration Picker View

/// Horizontal scrolling duration picker with glass effect
struct DurationPickerView: View {

    let durations: [Int]
    @Binding var selectedDuration: Int
    let onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(durations, id: \.self) { duration in
                    DurationChip(
                        duration: duration,
                        isSelected: duration == selectedDuration,
                        onTap: {
                            selectedDuration = duration
                            onSelect(duration)
                        }
                    )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)
        }
    }
}

// MARK: - Duration Chip

private struct DurationChip: View {

    let duration: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("\(duration)m")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.8))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(chipBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected ? DesignTokens.Colors.accent : Color.white.opacity(0.15),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: isSelected ? DesignTokens.Colors.accent.opacity(0.4) : .black.opacity(0.2),
                    radius: isSelected ? 12 : 6,
                    y: isSelected ? 6 : 3
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var chipBackground: some View {
        Group {
            if isSelected {
                LinearGradient(
                    colors: [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color.white.opacity(0.1)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DesignTokens.Gradients.primaryBackground
            .ignoresSafeArea()

        VStack(spacing: 20) {
            DurationPickerView(
                durations: [5, 15, 25, 45, 60],
                selectedDuration: .constant(25),
                onSelect: { _ in }
            )
        }
    }
}
