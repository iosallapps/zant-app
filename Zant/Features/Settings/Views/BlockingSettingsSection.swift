import SwiftUI

/// Blocking settings section with strictness and intervention duration pickers.
struct BlockingSettingsSection: View {

    var defaultStrictness: String
    var interventionDuration: Int
    var onUpdateStrictness: (BlockingStrictness) -> Void
    var onUpdateInterventionDuration: (Int) -> Void

    @State private var showStrictnessPicker = false
    @State private var showInterventionPicker = false

    var body: some View {
        SettingsSection(title: Strings.Profile.blocking) {
            VStack(spacing: 0) {
                Button {
                    showStrictnessPicker = true
                } label: {
                    SettingsRow(
                        icon: "shield.fill",
                        title: Strings.Profile.defaultStrictness,
                        value: defaultStrictness.capitalized
                    )
                }
                .buttonStyle(SettingsRowButtonStyle())
                SectionDivider()
                Button {
                    showInterventionPicker = true
                } label: {
                    SettingsRow(
                        icon: "timer",
                        title: Strings.Profile.interventionDuration,
                        value: Strings.Profile.interventionValue(interventionDuration)
                    )
                }
                .buttonStyle(SettingsRowButtonStyle())
            }
        }
        .sheet(isPresented: $showStrictnessPicker) {
            strictnessPickerSheet
        }
        .sheet(isPresented: $showInterventionPicker) {
            interventionPickerSheet
        }
    }

    // MARK: - Strictness Picker

    private var strictnessPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(BlockingStrictness.allCases, id: \.rawValue) { level in
                    Button {
                        onUpdateStrictness(level)
                        showStrictnessPicker = false
                    } label: {
                        HStack {
                            Text(level.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if level.rawValue == defaultStrictness {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(DesignTokens.Colors.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Strings.Profile.defaultStrictnessTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.General.done) { showStrictnessPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    // MARK: - Intervention Picker

    private var interventionPickerSheet: some View {
        NavigationStack {
            List {
                ForEach([6, 12, 18, 30], id: \.self) { seconds in
                    Button {
                        onUpdateInterventionDuration(seconds)
                        showInterventionPicker = false
                    } label: {
                        HStack {
                            Text(Strings.Profile.interventionSeconds(seconds))
                                .foregroundStyle(.primary)
                            Spacer()
                            if seconds == interventionDuration {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(DesignTokens.Colors.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Strings.Profile.interventionDurationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.General.done) { showInterventionPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
}
