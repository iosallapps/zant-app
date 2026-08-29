import SwiftUI

/// Thin divider line indented past the icon column, used inside settings sections.
struct SectionDivider: View {

    var leadingPadding: CGFloat = 62

    var body: some View {
        Rectangle()
            .fill(DesignTokens.Colors.divider)
            .frame(height: 1)
            .padding(.leading, leadingPadding)
    }
}
