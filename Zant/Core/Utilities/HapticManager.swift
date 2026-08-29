import UIKit

/// Consistent haptic feedback language throughout the app.
///
/// Usage:
/// - `.light` — selection toggles, slider snaps
/// - `.medium` — stone crack taps 3-4, significant actions
/// - `.heavy` — final stone shatter
/// - `.success` — session complete, gem reveal, permission granted, level up
/// - `.warning` — streak at risk
/// - `.error` — permission denied, session cancelled
enum HapticManager {

    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    static func light() {
        lightGenerator.impactOccurred()
    }

    static func medium() {
        mediumGenerator.impactOccurred()
    }

    static func heavy() {
        heavyGenerator.impactOccurred()
    }

    static func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    static func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    static func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    static func selection() {
        selectionGenerator.selectionChanged()
    }

    /// Prepare generators for low-latency feedback.
    static func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
    }
}
