import SwiftUI
import UIKit

// MARK: - Design Tokens

/// Centralized design system tokens. Never use magic numbers — always reference these.
enum DesignTokens {

    // MARK: - Colors

    enum Colors {
        // Background gradient — near-black with subtle violet undertone (not saturated purple)
        static let primaryGradientStart = Color(hex: "1A1232")  // Dark muted indigo
        static let primaryGradientEnd = Color(hex: "0D0B14")    // Near black

        // Accent — LiquidGlass teal/green palette
        static let accent = Color(red: 0.2, green: 0.9, blue: 0.5)      // Teal primary
        static let accentLight = Color(red: 0.45, green: 0.95, blue: 0.65)
        static let accentTeal = Color(red: 0.1, green: 0.6, blue: 0.55) // Darker teal

        static let success = Color(hex: "22C55E")
        static let warning = Color(hex: "F59E0B")
        static let error = Color(hex: "EF4444")

        static let scoreGreen = Color(hex: "22C55E")
        static let scoreYellow = Color(hex: "F59E0B")
        static let scoreRed = Color(hex: "EF4444")

        static let sliderGreen = Color(hex: "22C55E")
        static let sliderYellow = Color(hex: "EAB308")
        static let sliderOrange = Color(hex: "F97316")
        static let sliderRed = Color(hex: "EF4444")

        static let cardBackground = Color(uiColor: UIColor.systemBackground).opacity(0.08)
        static let surfacePrimary = Color(uiColor: UIColor.systemBackground)
        static let surfaceSecondary = Color(uiColor: UIColor.secondarySystemBackground)

        // Text hierarchy
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.6)  // raised from 0.5 for WCAG AA
        static let textTertiary = Color.white.opacity(0.4)
        static let textDisabled = Color.white.opacity(0.25)

        // Surfaces
        static let divider = Color.white.opacity(0.08)
        static let surfaceGlass = Color.white.opacity(0.04)
        static let surfaceGlassLight = Color.white.opacity(0.06)

        // Semantic
        static let errorBackground = Colors.error.opacity(0.12)

        // Glass — barely visible tint, not purple-heavy
        static let glassTint = Color(red: 0.45, green: 0.38, blue: 0.85).opacity(0.08)

        // Neutral icon color for non-interactive icons (settings, decorative)
        static let iconNeutral = Color.white.opacity(0.55)
    }

    // MARK: - Gradients

    enum Gradients {
        static let primaryBackground = LinearGradient(
            colors: [Colors.primaryGradientStart, Colors.primaryGradientEnd],
            startPoint: .top,
            endPoint: .bottom
        )

        static let gemShine = LinearGradient(
            colors: [.white.opacity(0.3), .clear, .white.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accentGlow = RadialGradient(
            colors: [Colors.accent.opacity(0.3), .clear],
            center: .center,
            startRadius: 0,
            endRadius: 80
        )

        static let warmGlow = RadialGradient(
            colors: [Colors.warning.opacity(0.3), .clear],
            center: .center,
            startRadius: 0,
            endRadius: 80
        )

        static let deepBackground = LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.02, blue: 0.08),
                Color(red: 0.02, green: 0.01, blue: 0.05),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 48
        static let massive: CGFloat = 64
        static let section: CGFloat = 28
    }

    // MARK: - Corner Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let card: CGFloat = 20  // LiquidGlass standard card radius
        static let pill: CGFloat = 100
    }

    // MARK: - Typography

    enum Typography {
        // Display & numbers — rounded for personality
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let counterLarge = Font.system(size: 56, weight: .bold, design: .rounded)
        static let counterMedium = Font.system(size: 40, weight: .bold, design: .rounded)
        static let scoreLarge = Font.system(size: 48, weight: .heavy, design: .rounded)

        // Metrics & Counters
        static let metricLarge = Font.system(size: 28, weight: .bold, design: .rounded)
        static let statDisplay = Font.system(size: 80, weight: .heavy, design: .rounded)
        static let statMedium = Font.system(size: 32, weight: .bold, design: .rounded)

        // Body text — system default for mature, professional feel
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .medium)
        static let caption = Font.system(size: 12, weight: .regular)

        // Badge & Small
        static let badge = Font.system(size: 11, weight: .semibold)
    }

    // MARK: - Animation

    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.8)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }

    // MARK: - Shadows

    enum Shadow {
        static let sm = (color: Color.black.opacity(0.1), radius: CGFloat(4), y: CGFloat(2))
        static let md = (color: Color.black.opacity(0.15), radius: CGFloat(8), y: CGFloat(4))
        static let lg = (color: Color.black.opacity(0.2), radius: CGFloat(16), y: CGFloat(8))
        static let glow = (color: Colors.accent.opacity(0.4), radius: CGFloat(12), y: CGFloat(0))
    }

    // MARK: - Icon Sizes

    enum IconSize {
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let huge: CGFloat = 48
    }

    // MARK: - Button Heights

    enum ButtonHeight {
        static let primary: CGFloat = 56    // Large primary actions
        static let secondary: CGFloat = 44  // iOS standard touch target
        static let compact: CGFloat = 36    // Smaller contexts
    }

    // MARK: - Component Sizes

    enum ComponentSize {
        static let cupImageLarge: CGFloat = 160    // Cup hero widget
        static let cupImageMedium: CGFloat = 120   // Cups collection
        static let cupImageSmall: CGFloat = 80     // Locked cups
        static let glowRadiusOuter: CGFloat = 400  // Outer glow circle
        static let glowRadiusInner: CGFloat = 240  // Inner glow circle
        static let widgetHeight: CGFloat = 280     // Hero widget height
        static let cardHeightMedium: CGFloat = 220 // Template card height
        static let timerMinWidth: CGFloat = 160    // Timer display min width
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
