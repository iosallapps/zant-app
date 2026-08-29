import SwiftUI

/// Block Templates library - Opal-inspired pre-made schedules
/// Allows users to quickly add blocking schedules from templates
struct BlockTemplatesView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    // MARK: - State

    @State private var selectedCategory: TemplateCategory = .focus
    @State private var selectedTemplate: BlockTemplate?
    @State private var showTemplateDetail: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AmbientBackground()
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.xxl) {
                        // Header
                        headerSection

                        // Category selector
                        categorySelector

                        // Templates grid
                        templatesGrid

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.top, DesignTokens.Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showTemplateDetail) {
            if let template = selectedTemplate {
                TemplateDetailSheet(
                    template: template,
                    onAdd: { addedTemplate in
                        addTemplate(addedTemplate)
                    }
                )
                .environment(appState)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Block Templates")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Quick-start blocking schedules")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DesignTokens.Spacing.sm)
    }

    // MARK: - Category Selector

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.md) {
                ForEach(TemplateCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: category == selectedCategory,
                        action: {
                            HapticManager.selection()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Templates Grid

    private var templatesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignTokens.Spacing.lg),
                GridItem(.flexible(), spacing: DesignTokens.Spacing.lg)
            ],
            spacing: DesignTokens.Spacing.lg
        ) {
            ForEach(filteredTemplates) { template in
                TemplateCard(template: template)
                    .onTapGesture {
                        HapticManager.medium()
                        selectedTemplate = template
                        showTemplateDetail = true
                    }
            }
        }
    }

    // MARK: - Computed

    private var filteredTemplates: [BlockTemplate] {
        BlockTemplate.allTemplates
            .filter { $0.category == selectedCategory }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    // MARK: - Actions

    private func addTemplate(_ template: BlockTemplate) {
        // Convert template to blocking rule
        let rule = template.toBlockingRule()

        Task {
            do {
                // Save rule to repository
                try await appState.blockingRuleRepository.save(rule: rule)

                // Register schedule with ScheduleBlockingService
                try ScheduleBlockingService.shared.registerSchedule(for: rule)

                // Success feedback
                HapticManager.success()

                // Dismiss
                dismiss()

            } catch {
                print("❌ Failed to add template: \(error)")
                // TODO: Show error toast
            }
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: TemplateCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.rawValue)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected
                            ? category.color.opacity(0.3)
                            : Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isSelected
                                    ? category.color.opacity(0.6)
                                    : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Template Card

private struct TemplateCard: View {
    let template: BlockTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Emoji & Premium badge
            HStack {
                Text(template.emoji)
                    .font(.system(size: 40))

                Spacer()

                if template.isPremium {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                        Text("PRO")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
            }

            // Name
            Text(template.name)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)

            // Time & Days
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: DesignTokens.Spacing.xs + 2) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                    Text(template.timeRangeString)
                        .font(.caption)
                }

                HStack(spacing: DesignTokens.Spacing.xs + 2) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                    Text(template.daysString)
                        .font(.caption)
                }
            }
            .foregroundStyle(.white.opacity(0.6))

            Spacer()

            // Add button
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                Text("Add")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(template.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(template.color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(height: DesignTokens.ComponentSize.cardHeightMedium)
        .background(
            ZStack {
                // Glass effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)

                // Gradient overlay
                LinearGradient(
                    colors: [
                        template.color.opacity(0.1),
                        template.color.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Border
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: template.color.opacity(0.1), radius: 10, y: 5)
    }
}

// MARK: - Template Detail Sheet

private struct TemplateDetailSheet: View {
    let template: BlockTemplate
    let onAdd: (BlockTemplate) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isAdding: Bool = false

    var body: some View {
        ZStack {
            AmbientBackground()
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.xxxl) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                // Emoji
                Text(template.emoji)
                    .font(.system(size: 80))

                // Name & Description
                VStack(spacing: DesignTokens.Spacing.md) {
                    Text(template.name)
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    Text(template.description)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Details
                VStack(spacing: 16) {
                    DetailRow(
                        icon: "clock.fill",
                        label: "Time",
                        value: template.timeRangeString
                    )

                    DetailRow(
                        icon: "calendar",
                        label: "Days",
                        value: template.daysString
                    )

                    DetailRow(
                        icon: "shield.fill",
                        label: "Strictness",
                        value: template.strictness.rawValue.capitalized
                    )
                }
                .padding(DesignTokens.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )

                Spacer()

                // Add button
                Button {
                    addTemplate()
                } label: {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        if isAdding {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }

                        Text(isAdding ? "Adding..." : "Add Template")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignTokens.ButtonHeight.primary)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                template.color,
                                template.color.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: template.color.opacity(0.3), radius: 20, y: 10)
                }
                .disabled(isAdding)
            }
            .padding(DesignTokens.Spacing.xxl)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.visible)
    }

    private func addTemplate() {
        isAdding = true
        HapticManager.success()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onAdd(template)
            dismiss()
        }
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            HStack(spacing: DesignTokens.Spacing.md - 2) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: DesignTokens.IconSize.lg)

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Preview

#Preview {
    BlockTemplatesView()
        .environment(AppState())
}
