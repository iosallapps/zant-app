import SwiftUI

struct ActiveSessionView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel: ActiveSessionViewModel?

    var body: some View {
        ZStack {
            DesignTokens.Gradients.deepBackground.ignoresSafeArea()

            ParticleCanvasView()
                .opacity(0.5)
                .ignoresSafeArea()

            if let viewModel {
                VStack(spacing: 0) {
                    topBar(viewModel)
                        .padding(.top, DesignTokens.Spacing.lg)

                    Spacer()

                    countdownRing(viewModel)

                    Spacer()

                    bottomControls(viewModel)
                        .padding(.bottom, DesignTokens.Spacing.xxl)
                }
                .padding(.horizontal, DesignTokens.Spacing.xl)

                if viewModel.showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
        }
        .onAppear {
            let vm = ActiveSessionViewModel(appState: appState)
            vm.setup()
            vm.startTimer()
            viewModel = vm
        }
        .onDisappear {
            viewModel?.stopTimer()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                viewModel?.handleEnteredForeground()
            case .background:
                viewModel?.handleEnteredBackground()
            default:
                break
            }
        }
        .confirmationDialog("End Session?", isPresented: Binding(
            get: { viewModel?.showStopConfirmation ?? false },
            set: { viewModel?.showStopConfirmation = $0 }
        )) {
            Button("Stop Session", role: .destructive) {
                Task {
                    await viewModel?.endSessionEarly()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will be saved but the session will end early.")
        }
        .confirmationDialog("Take a Break", isPresented: Binding(
            get: { viewModel?.showBreakPicker ?? false },
            set: { viewModel?.showBreakPicker = $0 }
        )) {
            Button("1 minute") { viewModel?.startBreak(minutes: 1) }
            Button("5 minutes") { viewModel?.startBreak(minutes: 5) }
            Button("15 minutes") { viewModel?.startBreak(minutes: 15) }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: viewModel?.showConfetti) { _, showConfetti in
            if showConfetti == true {
                HapticManager.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Top Bar

    private func topBar(_ vm: ActiveSessionViewModel) -> some View {
        HStack {
            Button {
                HapticManager.light()
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .glassEffect(.regular.interactive(), in: .circle)
            }

            Spacer()

            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: vm.modeIcon)
                    .font(.system(size: 14, weight: .semibold))
                Text(vm.modeName)
                    .font(DesignTokens.Typography.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .glassEffect(.regular, in: .capsule)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
    }

    // MARK: - Countdown Ring

    private func countdownRing(_ vm: ActiveSessionViewModel) -> some View {
        ZStack {
            Circle()
                .fill(DesignTokens.Colors.accent.opacity(0.12))
                .blur(radius: 60)
                .frame(width: 320, height: 320)

            ZantProgressRing(
                progress: vm.progress,
                lineWidth: 14,
                size: 280,
                showLabel: false
            )

            VStack(spacing: DesignTokens.Spacing.sm) {
                if vm.isOnBreak {
                    Text("Break")
                        .font(DesignTokens.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.Colors.warning)
                        .textCase(.uppercase)

                    Text(vm.formatTime(vm.breakSeconds))
                        .font(DesignTokens.Typography.counterLarge)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(DesignTokens.Animation.quick, value: vm.breakSeconds)
                } else {
                    Text(vm.formatTime(vm.remainingSeconds))
                        .font(DesignTokens.Typography.counterLarge)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(DesignTokens.Animation.quick, value: vm.remainingSeconds)

                    Text("remaining")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }

    // MARK: - Bottom Controls

    private func bottomControls(_ vm: ActiveSessionViewModel) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Elapsed progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(DesignTokens.Colors.accent)
                        .frame(
                            width: geo.size.width * CGFloat(vm.elapsedProgress),
                            height: 4
                        )
                        .animation(DesignTokens.Animation.smooth, value: vm.remainingSeconds)
                }
            }
            .frame(height: 4)

            // Take a Break button
            Button {
                HapticManager.selection()
                if vm.isOnBreak {
                    vm.endBreak()
                } else {
                    vm.showBreakPicker = true
                }
            } label: {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: vm.isOnBreak ? "play.fill" : "pause.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(vm.isOnBreak ? "Resume Session" : "Take a Break")
                        .font(DesignTokens.Typography.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.lg)
                .glassEffect(.regular.interactive(), in: .capsule)
            }
            .buttonStyle(.plain)

            // Stop Session
            Button {
                vm.showStopConfirmation = true
            } label: {
                Text("Stop Session")
                    .font(DesignTokens.Typography.subheadline)
                    .foregroundStyle(DesignTokens.Colors.error)
            }
        }
    }
}
