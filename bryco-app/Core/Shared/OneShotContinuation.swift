import Foundation

/// A bridge from callback/delegate APIs to `async`, guaranteeing the rule every checked
/// continuation must follow: resume exactly once.
///
/// - Late or duplicate callbacks are ignored instead of crashing the app.
/// - If the waiting task is cancelled, the caller gets `CancellationError` right away and
///   `onCancel` lets the underlying API stop (e.g. dismiss a sign-in sheet).
@MainActor
final class OneShotContinuation<Value> {
    private var continuation: CheckedContinuation<Value, Error>?

    /// Whether the continuation has already been resumed.
    private(set) var isFinished = false

    /// Resumes the waiting caller. Returns `false` (and does nothing) if it was already resumed.
    @discardableResult
    func resume(with result: sending Result<Value, Error>) -> Bool {
        guard !isFinished else { return false }
        isFinished = true
        let continuation = self.continuation
        self.continuation = nil
        continuation?.resume(with: result)
        return true
    }

    /// Starts a callback-based operation and suspends until it calls back, fails or is cancelled.
    static func run(
        start: (OneShotContinuation<Value>) -> Void,
        onCancel: @escaping @MainActor () -> Void = {}
    ) async throws -> Value {
        let oneShot = OneShotContinuation<Value>()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                // Cancelled before we even started: fail without starting the operation.
                guard !Task.isCancelled else {
                    oneShot.isFinished = true
                    continuation.resume(throwing: CancellationError())
                    return
                }
                oneShot.continuation = continuation
                start(oneShot)
            }
        } onCancel: {
            Task { @MainActor in
                if oneShot.resume(with: .failure(CancellationError())) {
                    onCancel()
                }
            }
        }
    }
}
