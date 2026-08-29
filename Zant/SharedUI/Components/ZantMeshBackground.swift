import SwiftUI

/// Animated mesh gradient background — violet/indigo palette matching Zant's brand.
struct ZantMeshBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            MeshGradient(
                width: 3, height: 3,
                points: [
                    .init(0, 0), .init(Float(0.5 + 0.04 * sin(t * 0.6)), 0), .init(1, 0),
                    .init(0, Float(0.5 + 0.03 * cos(t * 0.4))),
                    .init(Float(0.5 + 0.05 * cos(t * 0.7)), Float(0.5 + 0.05 * sin(t * 0.5))),
                    .init(1, Float(0.5 + 0.03 * sin(t * 0.8))),
                    .init(0, 1), .init(Float(0.5 + 0.04 * cos(t * 0.5)), 1), .init(1, 1)
                ],
                colors: [
                    DesignTokens.Colors.accent.opacity(0.08), Color(hex: "4A3ADB").opacity(0.05), Color(hex: "0D0B14"),
                    Color(hex: "1A1232").opacity(0.8), Color(hex: "0D0B14"), DesignTokens.Colors.accent.opacity(0.06),
                    Color(hex: "0D0B14"), Color(hex: "4A3ADB").opacity(0.04), Color(hex: "0D0B14")
                ]
            )
        }
        .ignoresSafeArea()
    }
}
