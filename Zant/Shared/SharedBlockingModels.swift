import Foundation

/// Blocking state shared between main app and extensions via app group UserDefaults.
/// Add this file to ALL target memberships.
struct BlockingState: Codable, Sendable {
    var isBlocking: Bool
    var sessionMode: String?
    var expiresAt: Date?
    var strictness: String? // BlockingStrictness.rawValue
}
