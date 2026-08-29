import SwiftUI

/// A selectable row for habit selection. Full-width with icon, text, and checkmark.
struct HabitChipView: View {

    let habit: Habit
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: habit.icon)
                    .font(.system(size: 16))
                    .frame(width: 24)

                Text(habit.chipLabel)
                    .font(DesignTokens.Typography.body)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(DesignTokens.Colors.success)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
            .if(isSelected) { view in
                view.glassEffect(
                    .regular.tint(DesignTokens.Colors.accent).interactive(),
                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                )
            }
            .if(!isSelected) { view in
                view
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            }
        }
        .buttonStyle(.plain)
        .animation(DesignTokens.Animation.spring, value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            HabitChipView(habit: .socialMediaScrolling, isSelected: false) {}
            HabitChipView(habit: .lateNightPhoneUse, isSelected: true) {}
        }
        .padding()
    }
}
