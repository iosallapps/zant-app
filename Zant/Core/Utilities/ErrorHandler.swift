import Foundation
import SwiftUI
import Combine

/// Centralized error handling service
/// Provides consistent error handling across the app
@MainActor
class ErrorHandler: ObservableObject {

    // MARK: - Singleton

    static let shared = ErrorHandler()

    private init() {}

    // MARK: - Published State

    @Published var currentError: AppError?
    @Published var showError: Bool = false

    // MARK: - Error Types

    enum AppError: LocalizedError, Identifiable {
        case timerServiceUnavailable
        case sessionAlreadyActive
        case screenTimePermissionDenied
        case databaseError(String)
        case networkError(String)
        case unknown(String)

        var id: String {
            switch self {
            case .timerServiceUnavailable: return "timer_service"
            case .sessionAlreadyActive: return "session_active"
            case .screenTimePermissionDenied: return "permission_denied"
            case .databaseError(let msg): return "db_\(msg)"
            case .networkError(let msg): return "net_\(msg)"
            case .unknown(let msg): return "unknown_\(msg)"
            }
        }

        var errorDescription: String? {
            switch self {
            case .timerServiceUnavailable:
                return "Timer service is not available. Please restart the app."
            case .sessionAlreadyActive:
                return "You already have an active session. Complete it before starting a new one."
            case .screenTimePermissionDenied:
                return "Screen Time permission is required to block apps. Please enable it in Settings."
            case .databaseError(let message):
                return "Database error: \(message)"
            case .networkError(let message):
                return "Network error: \(message)"
            case .unknown(let message):
                return "An error occurred: \(message)"
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .timerServiceUnavailable:
                return "Restart the app or contact support if the issue persists."
            case .sessionAlreadyActive:
                return "Go to the active session view to monitor your current session."
            case .screenTimePermissionDenied:
                return "Open Settings → Screen Time → Family Controls and allow Zant."
            case .databaseError:
                return "This error has been logged. Please try again or contact support."
            case .networkError:
                return "Check your internet connection and try again."
            case .unknown:
                return "Please try again or contact support if the issue persists."
            }
        }
    }

    // MARK: - Public Methods

    /// Handle and display an error
    func handle(_ error: AppError, context: String = "") {
        print("⚠️ ERROR [\(context)]: \(error.localizedDescription)")

        // Log to analytics/crashlytics
        logError(error, context: context)

        // Show to user
        currentError = error
        showError = true

        // Auto-dismiss after 5 seconds
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if currentError?.id == error.id {
                showError = false
            }
        }
    }

    /// Handle a standard Swift Error
    func handle(_ error: Error, context: String = "") {
        let appError: AppError

        // Map known errors
        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSURLErrorDomain:
                appError = .networkError(nsError.localizedDescription)
            case NSCocoaErrorDomain:
                appError = .databaseError(nsError.localizedDescription)
            default:
                appError = .unknown(error.localizedDescription)
            }
        } else {
            appError = .unknown(error.localizedDescription)
        }

        handle(appError, context: context)
    }

    /// Dismiss current error
    func dismiss() {
        showError = false
        currentError = nil
    }

    // MARK: - Private Helpers

    private func logError(_ error: AppError, context: String) {
        // TODO: Integrate with Firebase Crashlytics or Sentry
        // Crashlytics.crashlytics().record(error: error)

        // For now, just print
        print("📊 ANALYTICS: Error logged - \(error.id) in \(context)")
    }

    // MARK: - Safe Execution Helpers

    /// Execute an async throwing task with automatic error handling
    func safeExecute<T>(
        _ task: @escaping () async throws -> T,
        context: String,
        onSuccess: ((T) -> Void)? = nil,
        onError: ((AppError) -> Void)? = nil
    ) async {
        do {
            let result = try await task()
            await MainActor.run {
                onSuccess?(result)
            }
        } catch {
            await MainActor.run {
                let appError = AppError.unknown(error.localizedDescription)
                handle(appError, context: context)
                onError?(appError)
            }
        }
    }

    /// Execute a synchronous throwing task with automatic error handling
    func safeExecute<T>(
        _ task: @escaping () throws -> T,
        context: String,
        onSuccess: ((T) -> Void)? = nil,
        onError: ((AppError) -> Void)? = nil
    ) {
        do {
            let result = try task()
            onSuccess?(result)
        } catch {
            let appError = AppError.unknown(error.localizedDescription)
            handle(appError, context: context)
            onError?(appError)
        }
    }
}

// MARK: - View Extension for Error Handling

extension View {
    /// Add error handling overlay to any view
    func withErrorHandling() -> some View {
        modifier(ErrorHandlingModifier())
    }
}

struct ErrorHandlingModifier: ViewModifier {
    @StateObject private var errorHandler = ErrorHandler.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if errorHandler.showError, let error = errorHandler.currentError {
                    ErrorBanner(
                        error: error,
                        onDismiss: { errorHandler.dismiss() }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: errorHandler.showError)
                    .zIndex(999)
                }
            }
    }
}

// MARK: - Error Banner View

struct ErrorBanner: View {
    let error: ErrorHandler.AppError
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)

                Text(error.errorDescription ?? "An error occurred")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            if let recovery = error.recoverySuggestion {
                Text(recovery)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.red.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        Text("App Content")
        Spacer()
    }
    .withErrorHandling()
    .onAppear {
        ErrorHandler.shared.handle(.sessionAlreadyActive, context: "Preview")
    }
}
