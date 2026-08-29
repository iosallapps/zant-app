import SwiftUI

/// Pulsing indicator showing active app-blocking status or an empty state prompt.
struct ActiveBlocksIndicator: View {

    let isCurrentlyBlocking: Bool
    @State private var pulseBlocks = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: Strings.Dashboard.activeBlocks)

            if isCurrentlyBlocking {
                activeBlockingContent
            } else {
                noBlocksContent
            }
        }
    }

    // MARK: - Active Blocking

    private var activeBlockingContent: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DesignTokens.Colors.success)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.Dashboard.appsBlocked)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(Strings.Dashboard.appsBlockedSubtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Circle()
                .fill(DesignTokens.Colors.success)
                .frame(width: 8, height: 8)
        }
        .padding(14)
        .glassEffect(in: .rect(cornerRadius: 14))
    }

    // MARK: - No Blocks

    private var noBlocksContent: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.slash")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.3))
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.Dashboard.noActiveBlocks)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
                Text(Strings.Dashboard.noActiveBlocksSubtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }

            Spacer()
        }
        .padding(14)
        .glassEffect(in: .rect(cornerRadius: 14))
    }
}
