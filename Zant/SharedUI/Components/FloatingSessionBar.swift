import SwiftUI

struct FloatingSessionBar: View {

    @Environment(AppState.self) private var appState

    @Binding var showActiveSession: Bool

    @State private var remainingSeconds: Int = 0
    @State private var timerSubscription: Timer? = nil

    private var modeName: String {
        appState.activeSessionMode?.capitalized ?? "Focus"
    }

    private var targetMinutes: Int {
        appState.activeSessionTargetDuration
    }

    var body: some View {
        Button {
            HapticManager.light()
            showActiveSession = true
        } label: {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: "timer")
                    .font(.system(size: DesignTokens.IconSize.sm, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.accent)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text(modeName)
                        .font(DesignTokens.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text(formattedTime)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .contentTransition(.numericText())
                }

                Spacer()

                Button {
                    HapticManager.selection()
                    appState.isOnBreak.toggle()
                } label: {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Image(systemName: appState.isOnBreak ? "play.fill" : "pause.fill")
                            .font(.system(size: DesignTokens.IconSize.xs, weight: .semibold))
                        Text(appState.isOnBreak ? Strings.FloatingBar.resumeLabel : Strings.FloatingBar.breakLabel)
                            .font(DesignTokens.Typography.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .glassEffect(.regular.interactive(), in: .capsule)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .glassEffect(
                .regular.tint(DesignTokens.Colors.glassTint),
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.xl)
            )
        }
        .buttonStyle(FloatingBarButtonStyle())
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: appState.isOnBreak) { _, isOnBreak in
            if isOnBreak {
                stopTimer()
            } else {
                startTimer()
            }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        updateRemaining()
        timerSubscription = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                updateRemaining()
            }
        }
    }

    private func stopTimer() {
        timerSubscription?.invalidate()
        timerSubscription = nil
    }

    private func updateRemaining() {
        guard let startedAt = appState.activeSessionStartedAt else {
            remainingSeconds = 0
            return
        }
        let elapsed = Int(Date().timeIntervalSince(startedAt))
        let total = targetMinutes * 60
        remainingSeconds = max(total - elapsed, 0)
    }

    private var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Button Style

private struct FloatingBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(DesignTokens.Animation.quick, value: configuration.isPressed)
    }
}
