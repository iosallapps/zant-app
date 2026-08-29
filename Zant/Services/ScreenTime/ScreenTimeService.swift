import Foundation
#if !targetEnvironment(simulator)
import FamilyControls
#endif

/// Screen Time API service for FamilyControls authorization.
final class ScreenTimeService: ScreenTimeServiceProtocol, @unchecked Sendable {

    static let shared = ScreenTimeService()
    private init() {
        #if !targetEnvironment(simulator)
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        #endif
    }

    private(set) var isAuthorized: Bool = false

    func requestAuthorization() async throws {
        #if !targetEnvironment(simulator)
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        #else
        // Simulator stub
        isAuthorized = true
        #endif
    }

    func checkAuthorizationStatus() {
        #if !targetEnvironment(simulator)
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        #endif
    }
}
