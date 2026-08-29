import SwiftUI

// MARK: - Tag Selector View

/// Grid of session tag cards with glassmorphic design
struct TagSelectorView: View {

    @Binding var selectedTag: SessionTag
    let onSelect: (SessionTag) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: DesignTokens.Spacing.sm),
        GridItem(.flexible(), spacing: DesignTokens.Spacing.sm)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignTokens.Spacing.sm) {
            ForEach(SessionTag.allCases, id: \.self) { tag in
                TagCard(
                    tag: tag,
                    isSelected: tag == selectedTag,
                    onTap: {
                        selectedTag = tag
                        onSelect(tag)
                    }
                )
            }
        }
    }
}

// MARK: - Tag Card

private struct TagCard: View {

    let tag: SessionTag
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Icon with gradient background
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignTokens.Colors.accent.opacity(0.3), DesignTokens.Colors.accentTeal.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                    }

                    Image(systemName: tag.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.9))
                }
                .frame(height: 56)

                // Tag name
                Text(tag.rawValue)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .padding(DesignTokens.Spacing.md)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isSelected ? DesignTokens.Colors.accent : Color.white.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? DesignTokens.Colors.accent.opacity(0.4) : .black.opacity(0.3),
                radius: isSelected ? 16 : 8,
                y: isSelected ? 8 : 4
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var cardBackground: some View {
        ZStack {
            // Base background
            if isSelected {
                LinearGradient(
                    colors: [
                        DesignTokens.Colors.accent.opacity(0.25),
                        DesignTokens.Colors.accentTeal.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color.white.opacity(0.08)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DesignTokens.Gradients.primaryBackground
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 20) {
                Text("Select Focus Type")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TagSelectorView(
                    selectedTag: .constant(.deepWork),
                    onSelect: { _ in }
                )
            }
            .padding(DesignTokens.Spacing.xl)
        }
    }
}
