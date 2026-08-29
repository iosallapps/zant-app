import SwiftUI

// MARK: - GemType Visual Properties

extension GemType {

    var primaryColor: Color {
        switch self {
        case .stone: Color(red: 0.55, green: 0.52, blue: 0.48)
        case .quartz: Color(red: 0.92, green: 0.85, blue: 0.95)
        case .amethyst: Color(red: 0.58, green: 0.27, blue: 0.76)
        case .emerald: Color(red: 0.08, green: 0.66, blue: 0.38)
        case .ruby: Color(red: 0.84, green: 0.08, blue: 0.15)
        case .diamond: Color(red: 0.78, green: 0.88, blue: 0.98)
        case .obsidian: Color(red: 0.12, green: 0.13, blue: 0.18)
        }
    }

    /// Deep saturated body color (seen through the pavilion)
    var bodyColor: Color {
        switch self {
        case .stone: Color(red: 0.42, green: 0.40, blue: 0.36)
        case .quartz: Color(red: 0.82, green: 0.68, blue: 0.86)
        case .amethyst: Color(red: 0.40, green: 0.10, blue: 0.60)
        case .emerald: Color(red: 0.02, green: 0.42, blue: 0.22)
        case .ruby: Color(red: 0.62, green: 0.02, blue: 0.08)
        case .diamond: Color(red: 0.60, green: 0.72, blue: 0.88)
        case .obsidian: Color(red: 0.06, green: 0.06, blue: 0.10)
        }
    }

    /// Light highlight color (crown facet catches)
    var highlightColor: Color {
        switch self {
        case .stone: Color(red: 0.75, green: 0.72, blue: 0.68)
        case .quartz: Color(red: 0.98, green: 0.94, blue: 1.0)
        case .amethyst: Color(red: 0.82, green: 0.62, blue: 0.95)
        case .emerald: Color(red: 0.45, green: 0.92, blue: 0.65)
        case .ruby: Color(red: 1.0, green: 0.50, blue: 0.50)
        case .diamond: Color(red: 0.95, green: 0.97, blue: 1.0)
        case .obsidian: Color(red: 0.32, green: 0.34, blue: 0.42)
        }
    }

    var glowColor: Color {
        switch self {
        case .stone: .gray
        case .quartz: Color(red: 0.88, green: 0.73, blue: 0.89)
        case .amethyst: Color(red: 0.58, green: 0.27, blue: 0.76)
        case .emerald: Color(red: 0.08, green: 0.66, blue: 0.38)
        case .ruby: Color(red: 0.84, green: 0.08, blue: 0.15)
        case .diamond: Color(red: 0.70, green: 0.85, blue: 1.0)
        case .obsidian: Color(red: 0.20, green: 0.22, blue: 0.35)
        }
    }

    /// Fire/dispersion colors for rainbow flash (strongest in diamond)
    var fireColors: [Color] {
        switch self {
        case .diamond:
            [Color(red: 1.0, green: 0.9, blue: 0.7),
             Color(red: 0.7, green: 0.9, blue: 1.0),
             Color(red: 0.9, green: 0.7, blue: 1.0)]
        case .quartz:
            [Color(red: 0.95, green: 0.90, blue: 1.0),
             Color(red: 1.0, green: 0.95, blue: 0.98)]
        default:
            [highlightColor.opacity(0.6), highlightColor.opacity(0.3)]
        }
    }
}

// MARK: - Crown (Top) Shape

/// The flat table + upper crown facets of a brilliant-cut gem.
private struct CrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        // Top point → right shoulder → right girdle → left girdle → left shoulder → close
        path.move(to: CGPoint(x: w * 0.50, y: 0))
        path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 1.00, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.00, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.15))
        path.closeSubpath()
        return path
    }
}

/// The table facet (flat top window).
private struct TableShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.32, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.30))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.30))
        path.closeSubpath()
        return path
    }
}

// MARK: - Pavilion (Bottom) Shape

/// The lower pavilion of the gem (below the girdle).
private struct PavilionShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.00, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 1.00, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 1.00))
        path.closeSubpath()
        return path
    }
}

// MARK: - Full Gem Outline

private struct GemOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.50, y: 0))
        path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 1.00, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 1.00))
        path.addLine(to: CGPoint(x: w * 0.00, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.15))
        path.closeSubpath()
        return path
    }
}

// MARK: - Detailed Facet Lines

private struct DetailedFacetOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // ── Crown facets ──
        // Table edges
        path.move(to: CGPoint(x: w * 0.32, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.22))

        path.move(to: CGPoint(x: w * 0.28, y: h * 0.30))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.30))

        // Table side edges
        path.move(to: CGPoint(x: w * 0.32, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.30))

        path.move(to: CGPoint(x: w * 0.68, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.30))

        // Star facets (table to crown point)
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.50, y: 0))

        // Upper crown facets
        path.move(to: CGPoint(x: w * 0.32, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.15))

        path.move(to: CGPoint(x: w * 0.68, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.15))

        // Crown to girdle
        path.move(to: CGPoint(x: w * 0.28, y: h * 0.30))
        path.addLine(to: CGPoint(x: 0, y: h * 0.40))

        path.move(to: CGPoint(x: w * 0.72, y: h * 0.30))
        path.addLine(to: CGPoint(x: w, y: h * 0.40))

        // Additional crown kite facets
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.15))

        path.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.15))

        // ── Girdle ──
        path.move(to: CGPoint(x: 0, y: h * 0.40))
        path.addLine(to: CGPoint(x: w, y: h * 0.40))

        // Girdle subdivisions
        path.move(to: CGPoint(x: w * 0.25, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.38))

        path.move(to: CGPoint(x: w * 0.50, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.38))

        path.move(to: CGPoint(x: w * 0.75, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.38))

        // ── Pavilion facets ──
        // Main pavilion lines to culet
        path.move(to: CGPoint(x: 0, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h))

        path.move(to: CGPoint(x: w, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h))

        // Lower girdle facets
        path.move(to: CGPoint(x: w * 0.25, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h))

        path.move(to: CGPoint(x: w * 0.75, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h))

        // Mid-pavilion horizontal
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.62))

        return path
    }
}

// MARK: - Left Crown Highlight Shape

private struct LeftCrownHighlight: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        // Left crown kite facet area
        path.move(to: CGPoint(x: w * 0.50, y: 0))
        path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.15))
        path.closeSubpath()
        return path
    }
}

// MARK: - Right Pavilion Highlight Shape

private struct RightPavilionHighlight: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.70))
        path.closeSubpath()
        return path
    }
}

// MARK: - Gem View

struct GemView: View {

    let type: GemType
    var size: CGFloat = 48
    var isEarned: Bool = true

    private var gemW: CGFloat { size * 0.70 }
    private var gemH: CGFloat { size * 0.85 }

    var body: some View {
        ZStack {
            // ── Atmospheric glow ──
            if isEarned {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [type.glowColor.opacity(0.45), type.glowColor.opacity(0.12), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.7
                        )
                    )
                    .frame(width: size * 1.6, height: size * 1.6)
                    .blur(radius: size * 0.15)
            }

            // ── Pavilion (bottom) with deep body color ──
            PavilionShape()
                .fill(
                    LinearGradient(
                        colors: [type.bodyColor, type.bodyColor.opacity(0.7), type.primaryColor.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: gemW, height: gemH)

            // ── Pavilion inner refraction ──
            PavilionShape()
                .fill(
                    RadialGradient(
                        colors: [type.primaryColor.opacity(0.5), type.bodyColor.opacity(0.2), .clear],
                        center: UnitPoint(x: 0.5, y: 0.65),
                        startRadius: 0,
                        endRadius: gemW * 0.4
                    )
                )
                .frame(width: gemW, height: gemH)

            // ── Crown (top) with lighter gradient ──
            CrownShape()
                .fill(
                    LinearGradient(
                        colors: [type.highlightColor.opacity(0.6), type.primaryColor, type.bodyColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: gemW, height: gemH)

            // ── Table facet — window into the gem ──
            TableShape()
                .fill(
                    LinearGradient(
                        colors: [type.highlightColor.opacity(0.4), type.primaryColor.opacity(0.6), type.bodyColor.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: gemW, height: gemH)

            // ── Fire/dispersion flash (rainbow in diamond) ──
            TableShape()
                .fill(
                    AngularGradient(
                        colors: type.fireColors + [type.fireColors.first ?? .clear],
                        center: UnitPoint(x: 0.5, y: 0.26)
                    )
                )
                .frame(width: gemW, height: gemH)
                .opacity(isEarned ? 0.35 : 0)
                .blendMode(.screen)

            // ── Left crown highlight (bright specular) ──
            LeftCrownHighlight()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.7), .white.opacity(0.15), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: gemW, height: gemH)

            // ── Right pavilion internal reflection ──
            RightPavilionHighlight()
                .fill(
                    LinearGradient(
                        colors: [type.highlightColor.opacity(0.25), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: gemW, height: gemH)

            // ── Detailed facet lines ──
            DetailedFacetOverlay()
                .stroke(
                    Color.white.opacity(isEarned ? 0.12 : 0.04),
                    lineWidth: 0.5
                )
                .frame(width: gemW, height: gemH)

            // ── Outer edge highlight stroke ──
            GemOutlineShape()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.08), .white.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
                .frame(width: gemW, height: gemH)

            // ── Specular pinpoint highlight ──
            if isEarned {
                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: size * 0.06, height: size * 0.06)
                    .blur(radius: size * 0.015)
                    .offset(x: -gemW * 0.12, y: -gemH * 0.28)

                Circle()
                    .fill(.white.opacity(0.4))
                    .frame(width: size * 0.04, height: size * 0.04)
                    .blur(radius: size * 0.01)
                    .offset(x: gemW * 0.08, y: -gemH * 0.15)
            }
        }
        .frame(width: size, height: size)
        .saturation(isEarned ? 1.2 : 0)
        .opacity(isEarned ? 1 : 0.25)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        VStack(spacing: DesignTokens.Spacing.xxxl) {
            HStack(spacing: DesignTokens.Spacing.xl) {
                ForEach(GemType.allCases) { gem in
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        GemView(type: gem, size: 56, isEarned: true)
                        Text(gem.displayName)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }

            HStack(spacing: DesignTokens.Spacing.xxxl) {
                ForEach([GemType.ruby, .emerald, .diamond, .amethyst], id: \.self) { gem in
                    GemView(type: gem, size: 80, isEarned: true)
                }
            }

            HStack(spacing: DesignTokens.Spacing.xl) {
                GemView(type: .diamond, size: 100, isEarned: true)
                GemView(type: .diamond, size: 100, isEarned: false)
            }
        }
    }
}
