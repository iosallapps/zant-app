import SwiftUI
import SwiftData

// MARK: - Active Session View V2

struct ActiveSessionViewV2: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: ActiveSessionViewModelV2?
    @State private var showStopConfirmation = false

    var body: some View {
        ZStack {
            // Gradient background based on session tag
            if let viewModel {
                SessionGradientBackground(tag: viewModel.sessionTag)
            }

            // Main content
            if let viewModel {
                mainContent(viewModel)
            }

            // Completion celebration
            if let viewModel, viewModel.showCompletionCelebration {
                CompletionCelebrationView(
                    duration: viewModel.sessionState?.durationMinutes ?? 25,
                    tag: viewModel.sessionTag,
                    isPresented: Binding(
                        get: { viewModel.showCompletionCelebration },
                        set: { _ in dismiss() }
                    )
                )
            }
        }
        .onAppear {
            setupViewModel()
        }
        .onDisappear {
            viewModel?.onDisappear()
        }
        .confirmationDialog(
            "End Session Early?",
            isPresented: $showStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Stop Session", role: .destructive) {
                Task {
                    await viewModel?.stopSession()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will be saved but the session will end early.")
        }
    }

    // MARK: - Main Content

    private func mainContent(_ viewModel: ActiveSessionViewModelV2) -> some View {
        VStack(spacing: 0) {
            // Top bar
            topBar(viewModel)
                .padding(.top, DesignTokens.Spacing.xl)

            Spacer()

            // Timer display
            timerDisplay(viewModel)

            Spacer()

            // Bottom controls
            bottomControls(viewModel)
                .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }

    // MARK: - Top Bar

    private func topBar(_ viewModel: ActiveSessionViewModelV2) -> some View {
        HStack {
            // Session tag
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.sessionTag.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 12))
                    Text("\(viewModel.blockedAppsCount) apps blocked")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Timer Display

    private func timerDisplay(_ viewModel: ActiveSessionViewModelV2) -> some View {
        ZStack {
            // Progress ring
            CircularProgressRing(
                progress: viewModel.progress,
                lineWidth: 14,
                accentColor: .white
            )
            .frame(width: 280, height: 280)

            // Time text
            VStack(spacing: 8) {
                Text(viewModel.remainingTime)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text(viewModel.formattedProgress)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Bottom Controls

    private func bottomControls(_ viewModel: ActiveSessionViewModelV2) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Motivational text
            Text("Stay focused. You've got this!")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            // Stop button
            Button {
                showStopConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 16))
                    Text("Stop Session")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Setup

    private func setupViewModel() {
        guard let timerService = appState.timerService else {
            print("⚠️ TimerService not initialized")
            return
        }

        let vm = ActiveSessionViewModelV2(
            appState: appState,
            timerService: timerService
        )
        vm.onAppear()
        viewModel = vm
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        ActiveSessionViewV2()
            .environment(AppState())
            .modelContainer(for: FocusSession.self)
    }
}
