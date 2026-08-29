import SwiftUI
import SwiftData
#if !targetEnvironment(simulator)
import FamilyControls
#endif

// MARK: - Focus View V2

struct FocusViewV2: View {

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: FocusViewModelV2?
    @State private var showAppPicker = false

    var body: some View {
        ZStack {
            // Background
            AmbientBackground()

            // Main content
            if let viewModel {
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.section) {
                        // Header
                        headerSection
                            .staggeredAppear(index: 0)

                        // Duration picker
                        durationSection(viewModel)
                            .staggeredAppear(index: 1)

                        // Tag selector
                        tagSection(viewModel)
                            .staggeredAppear(index: 2)

                        // App selection
                        appSelectionSection(viewModel)
                            .staggeredAppear(index: 3)

                        // Start button
                        startButton(viewModel)
                            .staggeredAppear(index: 4)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.xl)
                    .padding(.vertical, DesignTokens.Spacing.lg)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupViewModel()
        }
        #if !targetEnvironment(simulator)
        .familyActivityPicker(
            isPresented: $showAppPicker,
            selection: Binding(
                get: { FamilyActivitySelection() },
                set: { selection in
                    viewModel?.updateSelectedAppsFromSelection(selection)
                }
            )
        )
        #endif
        .sheet(isPresented: Binding(
            get: { viewModel?.showPaywall ?? false },
            set: { _ in }
        )) {
            if let source = viewModel?.paywallSource {
                PaywallViewV2(source: source, canDismiss: source != .sessionLimit)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Start Focus Session")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Block distractions and build your streak")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Duration Section

    private func durationSection(_ viewModel: FocusViewModelV2) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Duration")

            DurationPickerView(
                durations: viewModel.durations,
                selectedDuration: Binding(
                    get: { viewModel.selectedDuration },
                    set: { _ in }
                ),
                onSelect: { duration in
                    viewModel.selectDuration(duration)
                }
            )
        }
    }

    // MARK: - Tag Section

    private func tagSection(_ viewModel: FocusViewModelV2) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Focus Type")

            TagSelectorView(
                selectedTag: Binding(
                    get: { viewModel.selectedTag },
                    set: { _ in }
                ),
                onSelect: { tag in
                    viewModel.selectTag(tag)
                }
            )
        }
    }

    // MARK: - App Selection

    private func appSelectionSection(_ viewModel: FocusViewModelV2) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Block Distractions")

            PremiumCard(
                title: viewModel.selectedAppsCount > 0 ? "\(viewModel.selectedAppsCount) Apps Selected" : "Select Apps to Block",
                subtitle: viewModel.selectedAppsCount > 0 ? "Tap to modify selection" : "Block distracting apps during your focus session",
                icon: viewModel.selectedAppsCount > 0 ? "checkmark.shield.fill" : "app.badge.fill",
                accentColor: viewModel.selectedAppsCount > 0 ? DesignTokens.Colors.success : DesignTokens.Colors.accent,
                action: {
                    showAppPicker = true
                }
            ) {
                // Selected apps display (if any)
                #if !targetEnvironment(simulator)
                if viewModel.selectedAppsCount > 0 {
                    if let selection = viewModel.appSelection {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(selection.applicationTokens.prefix(6)), id: \.self) { token in
                                    Label(token)
                                        .labelStyle(.iconOnly)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.15),
                                                    Color.white.opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                }

                                if selection.applicationTokens.count > 6 {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 48, height: 48)

                                        Text("+\(selection.applicationTokens.count - 6)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.7))
                                    }
                                }
                            }
                        }
                    }
                }
                #endif
            }
        }
    }

    // MARK: - Start Button

    private func startButton(_ viewModel: FocusViewModelV2) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.error)
                    .multilineTextAlignment(.center)
            }

            // Validation message
            let validation = viewModel.validateCanStart()
            if !validation.canStart, let reason = validation.reason {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                    Text(reason)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(DesignTokens.Colors.warning)
            }

            // Start button
            Button {
                Task {
                    await viewModel.startSession()
                }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isStarting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Text(viewModel.isStarting ? "Starting..." : "Start Session")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: viewModel.canStartSession
                            ? [DesignTokens.Colors.accent, DesignTokens.Colors.accentTeal]
                            : [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: viewModel.canStartSession
                        ? DesignTokens.Colors.accent.opacity(0.3)
                        : .clear,
                    radius: 12,
                    y: 6
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canStartSession || viewModel.isStarting)
        }
        .padding(.top, DesignTokens.Spacing.lg)
    }

    // MARK: - Setup

    private func setupViewModel() {
        guard let timerService = appState.timerService else {
            print("⚠️ TimerService not initialized")
            return
        }

        viewModel = FocusViewModelV2(
            appState: appState,
            timerService: timerService,
            modelContext: modelContext
        )

        Task {
            await viewModel?.onAppear()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FocusViewV2()
            .environment(AppState())
            .modelContainer(for: FocusSession.self, inMemory: true)
    }
}
