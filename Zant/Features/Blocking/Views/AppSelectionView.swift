import SwiftUI
#if !targetEnvironment(simulator)
import FamilyControls
#endif

/// Wraps Apple's FamilyActivityPicker in a Zant-branded view.
/// Presented as a sheet from Dashboard "Block Apps" or Blocking settings.
struct AppSelectionView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: BlockingViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                ZantMeshBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.xl) {
                        headerSection
                        pickerSection
                        actionButtons
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.top, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.huge)
                }
            }
            .navigationTitle("Select Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }
            }
            .task {
                let vm = BlockingViewModel(appState: appState)
                await vm.loadData()
                viewModel = vm
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignTokens.Colors.accent.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.accent)
            }

            Text("Choose apps to block during focus sessions")
                .font(DesignTokens.Typography.subheadline)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)

            if let vm = viewModel {
                Text("\(vm.selectedAppCount) apps & categories selected")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
        }
    }

    private var pickerSection: some View {
        #if !targetEnvironment(simulator)
        FamilyActivityPicker(
            selection: Binding(
                get: { viewModel?.selectedApps ?? FamilyActivitySelection() },
                set: { viewModel?.selectedApps = $0 }
            )
        )
        .frame(minHeight: 400)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        #else
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "iphone.slash")
                .font(.system(size: 40))
                .foregroundStyle(DesignTokens.Colors.textTertiary)
            Text("App picker requires a physical device")
                .font(DesignTokens.Typography.subheadline)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .frame(minHeight: 300)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(DesignTokens.Colors.surfaceGlass)
        )
        #endif
    }

    private var actionButtons: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ZantButton(.glass, title: "Save Selection", icon: "checkmark") {
                Task {
                    await viewModel?.saveAppSelection()
                    dismiss()
                }
            }

            if viewModel?.isBlocking == false {
                let hasSelection = (viewModel?.selectedAppCount ?? 0) > 0
                ZantButton(.glass, title: "Save & Block Now", icon: "lock.fill") {
                    Task {
                        await viewModel?.saveAppSelection()
                        await viewModel?.blockNow()
                        dismiss()
                    }
                }
                .disabled(!hasSelection)
                .opacity(hasSelection ? 1 : 0.5)
            }
        }
    }
}
