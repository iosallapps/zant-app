import SwiftUI
import SwiftData

// MARK: - Recent Sessions Card

struct RecentSessionsCard: View {

    let sessions: [FocusSession]
    let onViewAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Recent Sessions") {
                if !sessions.isEmpty {
                    Button(action: onViewAll) {
                        Text("View All")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DesignTokens.Colors.accent)
                    }
                }
            }

            if sessions.isEmpty {
                emptyState
            } else {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(sessions.prefix(3), id: \.id) { session in
                        sessionRow(session)
                    }
                }
            }
        }
    }

    // MARK: - Session Row

    private func sessionRow(_ session: FocusSession) -> some View {
        HStack(spacing: 12) {
            // Tag indicator
            if let tag = SessionTag(rawValue: session.tag) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: tag.gradient.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: tagIcon(for: tag))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.tag.capitalized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 4) {
                    Text("\(session.durationMinutes) min")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))

                    Text("•")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.4))

                    Text(timeAgoString(from: session.endDate))
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()

            // Completion checkmark
            if session.completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(DesignTokens.Colors.success)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.3))

            Text("No sessions yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))

            Text("Start your first focus session to see it here")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xxl)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    // MARK: - Helpers

    private func tagIcon(for tag: SessionTag) -> String {
        switch tag {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .deepWork: return "brain.head.profile"
        case .reading: return "text.book.closed.fill"
        case .exercise: return "figure.run"
        case .creative: return "paintpalette.fill"
        case .focus: return "bolt.fill"
        }
    }

    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let difference = now.timeIntervalSince(date)

        let hours = Int(difference / 3600)
        let days = Int(difference / 86400)

        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            // With sessions
            RecentSessionsCard(
                sessions: [
                    FocusSession(
                        startDate: Date().addingTimeInterval(-7200),
                        endDate: Date().addingTimeInterval(-5700),
                        durationMinutes: 25,
                        tag: "deepWork",
                        blockedAppTokens: [],
                        completed: true
                    ),
                    FocusSession(
                        startDate: Date().addingTimeInterval(-14400),
                        endDate: Date().addingTimeInterval(-11700),
                        durationMinutes: 45,
                        tag: "study",
                        blockedAppTokens: [],
                        completed: true
                    )
                ],
                onViewAll: {}
            )

            // Empty state
            RecentSessionsCard(
                sessions: [],
                onViewAll: {}
            )
        }
        .padding()
    }
}

