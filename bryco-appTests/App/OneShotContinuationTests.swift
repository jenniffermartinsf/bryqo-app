import Foundation
import Testing
@testable import bryco_app

private struct Boom: Error, Equatable {}

/// Covers the "resume exactly once" bridge used by Sign in with Apple.
@MainActor
@Suite("One-shot continuation")
struct OneShotContinuationTests {

    @Test("The first callback wins; later ones are ignored instead of crashing")
    func duplicateCallbacksAreIgnored() async throws {
        var second: Bool?
        let value = try await OneShotContinuation<Int>.run { oneShot in
            oneShot.resume(with: .success(1))
            second = oneShot.resume(with: .success(2))
            oneShot.resume(with: .failure(Boom()))
        }

        #expect(value == 1)
        #expect(second == false)
    }

    @Test("A failing callback becomes a thrown error")
    func failureIsThrown() async {
        await #expect(throws: Boom()) {
            try await OneShotContinuation<Int>.run { $0.resume(with: .failure(Boom())) }
        }
    }

    @Test("A delegate that calls back later still resumes the caller")
    func asyncCallback() async throws {
        let value = try await OneShotContinuation<String>.run { oneShot in
            Task { @MainActor in
                await Task.yield()
                oneShot.resume(with: .success("ok"))
            }
        }

        #expect(value == "ok")
    }

    @Test("Cancelling the waiting task throws CancellationError and stops the operation")
    func cancellation() async {
        var stopped = false
        var pending: OneShotContinuation<Int>?

        let task = Task { @MainActor in
            try await OneShotContinuation<Int>.run(start: { pending = $0 }, onCancel: { stopped = true })
        }
        while pending == nil { await Task.yield() }
        task.cancel()

        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(stopped)
        // The real callback arriving afterwards is ignored.
        #expect(pending?.resume(with: .success(1)) == false)
    }
}
