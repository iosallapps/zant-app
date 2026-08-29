import SwiftUI

/// Quick Timer sheet - Opal-inspired fast session start
/// Allows users to quickly start a session without navigating to Focus tab
struct QuickTimerSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    // MARK: - State

    @State private var minutes: Int = 20
    @State private var selectedTag: SessionTag = .focus
    @State private var isStarting: Bool = false

    // MARK: - Constants

    private let minDuration: Int = 5
    private let maxDuration: Int = 120
    private let increment: Int = 5

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            AmbientBackground()
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.xxxl) {
                // Header
                headerSection

                // Timer controls
                timerControlSection

                // Tag selector
                tagSelectorSection

                Spacer()

                // Action buttons
                actionButtonsSection
            }
            .padding(.horizontal, DesignTokens.Spacing.xxl)
            .padding(.top, DesignTokens.Spacing.huge - 8)
            .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            HStack {
                Spacer()

                Button {
                    HapticManager.light()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            Text("Quick Timer")
                .font(.title.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Start a focus session in seconds")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Timer Control

    private var timerControlSection: some View {
        HStack(spacing: DesignTokens.Spacing.xl) {
            // Decrease button
            Button {
                decreaseTime()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(minutes > minDuration ? .white.opacity(0.6) : .white.opacity(0.2))
            }
            .disabled(minutes <= minDuration)

            // Time display
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text("\(minutes)")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .frame(minWidth: DesignTokens.ComponentSize.timerMinWidth)

                Text("minutes")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            // Increase button
            Button {
                increaseTime()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(minutes < maxDuration ? DesignTokens.Colors.accent : .white.opacity(0.2))
            }
            .disabled(minutes >= maxDuration)
        }
        .padding(.vertical, DesignTokens.Spacing.xl)
    }

    // MARK: - Tag Selector

    private var tagSelectorSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Tag")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.md - 2) {
                    ForEach(SessionTag.allCases, id: \.rawValue) { tag in
                        TagChip(
                            tag: tag,
                            isSelected: tag == selectedTag,
                            action: {
                                HapticManager.selection()
                                withAnimation(DesignTokens.Animation.spring) {
                                    selectedTag = tag
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Start button
            Button {
                startQuickSession()
            } label: {
                HStack(spacing: DesignTokens.Spacing.md) {
                    if isStarting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Text(isStarting ? "Starting..." : "Start Timer")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: DesignTokens.ButtonHeight.primary)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: [
                            DesignTokens.Colors.accent,
                            DesignTokens.Colors.accent.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: DesignTokens.Colors.accent.opacity(0.3), radius: 20, y: 10)
            }
            .disabled(isStarting)

            // Cancel button
            Button {
                HapticManager.light()
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignTokens.ButtonHeight.secondary)
            }
        }
    }

    // MARK: - Actions

    private func decreaseTime() {
        guard minutes > minDuration else { return }
        HapticManager.selection()
        withAnimation(DesignTokens.Animation.spring) {
            minutes = max(minDuration, minutes - increment)
        }
    }

    private func increaseTime() {
        guard minutes < maxDuration else { return }
        HapticManager.selection()
        withAnimation(DesignTokens.Animation.spring) {
            minutes = min(maxDuration, minutes + increment)
        }
    }

    private func startQuickSession() {
        // Prevent multiple starts
        guard !isStarting else { return }
        guard appState.activeSessionStartedAt == nil else {
            // Already has active session
            dismiss()
            return
        }

        isStarting = true
        HapticManager.success()

        // Ensure TimerService is initialized
        guard let timerService = appState.timerService else {
            print("⚠️ TimerService not initialized")
            fallbackStartSession()
            return
        }

        Task {
            do {
                // Create session configuration
                let config = SessionConfigurationDTO(
                    durationMinutes: minutes,
                    tag: selectedTag,
                    blockedAppTokens: [], // Will use saved app selection
                    enableBreaks: false
                )

                // Start session via TimerService
                try await timerService.startSession(configuration: config)

                // Update AppState for UI reactivity
                await MainActor.run {
                    appState.activeSessionStartedAt = Date()
                    appState.activeSessionTargetDuration = minutes
                    appState.activeSessionMode = FocusMode.normal.rawValue
                    appState.activeSessionTag = selectedTag.rawValue

                    // Dismiss sheet and navigate to active session
                    isStarting = false
                    dismiss()
                }

            } catch {
                print("❌ Failed to start quick session: \(error)")
                await MainActor.run {
                    isStarting = false
                }
            }
        }
    }

    // MARK: - Fallback

    /// Fallback for when TimerService isn't available (backwards compatibility)
    private func fallbackStartSession() {
        appState.activeSessionStartedAt = Date()
        appState.activeSessionTargetDuration = minutes
        appState.activeSessionMode = FocusMode.normal.rawValue
        appState.activeSessionTag = selectedTag.rawValue

        isStarting = false
        dismiss()
    }
}

// MARK: - Tag Chip Component

private struct TagChip: View {
    let tag: SessionTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.xs + 2) {
                Image(systemName: tag.icon)
                    .font(.system(size: 12))
                Text(tag.rawValue)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md - 2)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected
                            ? DesignTokens.Colors.accent.opacity(0.2)
                            : Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                isSelected
                                    ? DesignTokens.Colors.accent.opacity(0.5)
                                    : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    QuickTimerSheet()
        .environment(AppState())
}
