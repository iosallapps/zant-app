import SwiftUI

/// Create or edit a blocking schedule rule.
struct BlockingScheduleView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: BlockingViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                ZantMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        nameField
                        timeSection
                        daysSection
                        strictnessSection
                        saveButton
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.top, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.huge)
                }
            }
            .navigationTitle("New Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }
            }
            .task {
                viewModel = BlockingViewModel(appState: appState)
            }
        }
    }

    // MARK: - Name

    private var nameField: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Name")

            TextField("e.g. Work Focus", text: Binding(
                get: { viewModel?.newRuleName ?? "" },
                set: { viewModel?.newRuleName = $0 }
            ))
            .font(DesignTokens.Typography.body)
            .foregroundStyle(DesignTokens.Colors.textPrimary)
            .padding(DesignTokens.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(DesignTokens.Colors.surfaceGlassLight)
            )
        }
    }

    // MARK: - Time

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Time")

            HStack(spacing: DesignTokens.Spacing.md) {
                timeCard(label: "Start", time: Binding(
                    get: { viewModel?.newRuleStartTime ?? .now },
                    set: { viewModel?.newRuleStartTime = $0 }
                ))
                timeCard(label: "End", time: Binding(
                    get: { viewModel?.newRuleEndTime ?? .now },
                    set: { viewModel?.newRuleEndTime = $0 }
                ))
            }
        }
    }

    private func timeCard(label: String, time: Binding<Date>) -> some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(label)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Colors.textSecondary)

            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(DesignTokens.Colors.surfaceGlassLight)
        )
    }

    // MARK: - Days

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Days")

            let days = [
                (1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S"),
            ]

            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(days, id: \.0) { day, label in
                    let isSelected = viewModel?.newRuleDays.contains(day) ?? false
                    Button {
                        if isSelected {
                            viewModel?.newRuleDays.remove(day)
                        } else {
                            viewModel?.newRuleDays.insert(day)
                        }
                    } label: {
                        Text(label)
                            .font(DesignTokens.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSelected ? DesignTokens.Colors.textPrimary : DesignTokens.Colors.textTertiary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(isSelected ? DesignTokens.Colors.accent.opacity(0.3) : DesignTokens.Colors.surfaceGlassLight)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Strictness

    private var strictnessSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Strictness")

            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(BlockingStrictness.allCases, id: \.rawValue) { level in
                    let isSelected = viewModel?.newRuleStrictness == level
                    Button {
                        viewModel?.newRuleStrictness = level
                    } label: {
                        Text(level.displayName)
                            .font(DesignTokens.Typography.subheadline)
                            .foregroundStyle(isSelected ? DesignTokens.Colors.textPrimary : DesignTokens.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignTokens.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                                    .fill(isSelected ? DesignTokens.Colors.accent.opacity(0.2) : DesignTokens.Colors.surfaceGlass)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            if let error = viewModel?.ruleValidationError {
                Text(error)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.error)
            }

            ZantButton(.glass, title: "Create Schedule", icon: "calendar.badge.plus") {
                Task {
                    await viewModel?.createRule()
                    if viewModel?.ruleValidationError == nil {
                        dismiss()
                    }
                }
            }
            .disabled(viewModel?.canCreateRule == false)
            .opacity(viewModel?.canCreateRule == false ? 0.5 : 1)
        }
        .padding(.top, DesignTokens.Spacing.md)
    }
}
