import Foundation
import Testing
@testable import bryco_app

/// Records sleeps and reported issues so retry behavior can be checked without waiting.
@MainActor
private final class Harness {
    var sleeps: [TimeInterval] = []
    var issues: [ContentIssue] = []
    var clock = Date(timeIntervalSince1970: 1_800_000_000)

    func repository(_ client: FakeHTTPClient, cache: ContentCache = tempCache(),
                    policy: RetryPolicy = RetryPolicy(jitter: { 1 })) -> ContentRepository {
        ContentRepository(
            service: ContentService(client: client), cache: cache, bundled: bundled, bundledVersion: 1,
            retryPolicy: policy,
            sleep: { [weak self] seconds in await MainActor.run { self?.sleeps.append(seconds) } },
            now: { [unowned self] in self.clock },
            report: { [weak self] in self?.issues.append($0) }
        )
    }
}

@MainActor
@Suite("Network error handling")
struct NetworkErrorHandlingTests {

    private let ok = FakeHTTPClient.Reply.response(status: 200, body: encoded(catalog(version: 2)))

    @Test("Backoff doubles each retry and is capped")
    func backoff() {
        let policy = RetryPolicy(maxAttempts: 10, baseDelay: 1, maxDelay: 30, jitter: { 1 })

        #expect((1...6).map { policy.delay(beforeRetry: $0) } == [1, 2, 4, 8, 16, 30])
        #expect(policy.delay(beforeRetry: 1, retryAfter: 12) == 12)
        #expect(policy.delay(beforeRetry: 1, retryAfter: 600) == 30)
    }

    @Test("Jitter spreads the delay around the exponential value")
    func jitter() {
        let low = RetryPolicy(jitter: { 0.8 }).delay(beforeRetry: 3)
        let high = RetryPolicy(jitter: { 1.2 }).delay(beforeRetry: 3)

        #expect(low == 3.2)
        #expect(high == 4.8)
    }

    @Test("A timeout is retried with backoff and then succeeds, with nothing reported")
    func timeoutRecovers() async {
        let harness = Harness()
        let client = FakeHTTPClient(sequence: [.failure(.timedOut), .failure(.timedOut), ok])
        let repository = harness.repository(client)

        await repository.refresh()

        #expect(client.requests.count == 3)
        #expect(harness.sleeps == [1, 2])
        #expect(repository.version == 2)
        #expect(repository.lastFailure == nil)
        #expect(harness.issues.isEmpty)
    }

    @Test("A 5xx that never recovers stops after the last attempt and is reported once")
    func serverErrorGivesUp() async {
        let harness = Harness()
        let client = FakeHTTPClient(.response(status: 503))
        let repository = harness.repository(client)

        await repository.refresh()

        #expect(client.requests.count == 3)
        #expect(harness.issues == [.fetchFailed(.server(status: 503), attempts: 3)])
        #expect(repository.units == bundled)
    }

    @Test("429 waits for the server's Retry-After")
    func rateLimitHonorsRetryAfter() async {
        let harness = Harness()
        let client = FakeHTTPClient(sequence: [.response(status: 429, headers: ["Retry-After": "7"]), ok])
        let repository = harness.repository(client)

        await repository.refresh()

        #expect(harness.sleeps == [7])
        #expect(repository.version == 2)
    }

    @Test("4xx and invalid JSON are never retried, only reported", arguments: [
        (FakeHTTPClient.Reply.response(status: 404), NetworkFailure.client(status: 404)),
        (.response(status: 200, body: Data("{".utf8)), .invalidResponse)
    ])
    func permanentFailuresAreNotRetried(reply: FakeHTTPClient.Reply, failure: NetworkFailure) async {
        let harness = Harness()
        let client = FakeHTTPClient(reply)
        let repository = harness.repository(client)

        await repository.refresh()

        #expect(client.requests.count == 1)
        #expect(harness.sleeps.isEmpty)
        #expect(harness.issues == [.fetchFailed(failure, attempts: 1)])
    }

    @Test("Offline is not retried or reported; it waits for the connection to come back")
    func offlineWaitsForConnection() async {
        let harness = Harness()
        let client = FakeHTTPClient(sequence: [.failure(.notConnectedToInternet), ok])
        let repository = harness.repository(client)

        await repository.refresh()
        #expect(client.requests.count == 1)
        #expect(repository.isWaitingForConnection)
        #expect(harness.issues.isEmpty)

        await repository.connectionRestored()
        #expect(client.requests.count == 2)
        #expect(repository.version == 2)
        #expect(!repository.isWaitingForConnection)
    }

    @Test("Going back online does nothing when no fetch is waiting")
    func connectionRestoredIsIdleWhenNotWaiting() async {
        let client = FakeHTTPClient(ok)
        let repository = Harness().repository(client)

        await repository.connectionRestored()

        #expect(client.requests.isEmpty)
    }

    @Test("Invalid lessons in a valid catalog are reported by id")
    func droppedLessonsAreReported() async {
        let harness = Harness()
        var dto = catalog(version: 2)
        let unit = dto.units[0]
        let broken = LessonDTO(id: "quebrada", title: "x", subtitle: "", estimatedMinutes: 1, xpReward: 1,
                               materialReward: "", steps: [])
        dto = ContentCatalogDTO(version: 2, units: [UnitDTO(id: unit.id, title: unit.title, subtitle: unit.subtitle,
                                                            lessons: unit.lessons + [broken])])
        let repository = harness.repository(FakeHTTPClient(.response(status: 200, body: encoded(dto))))

        await repository.refresh()

        #expect(harness.issues == [.lessonsDropped(["quebrada"])])
        #expect(repository.version == 2)
    }

    @Test("The stale-content notice appears only after a week without reaching the server")
    func staleNotice() async {
        let harness = Harness()
        let cache = tempCache()
        let repository = harness.repository(FakeHTTPClient(.failure(.notConnectedToInternet)), cache: cache)

        #expect(!repository.showsStaleContentNotice)
        harness.clock.addTimeInterval(8 * 24 * 60 * 60)
        #expect(repository.showsStaleContentNotice)


        // Reaching the server once (even a 304) clears it, and the next launch remembers.
        let online = harness.repository(FakeHTTPClient(.response(status: 304)), cache: cache)
        await online.refresh()
        #expect(!online.showsStaleContentNotice)
        #expect(!harness.repository(FakeHTTPClient(.response(status: 304)), cache: cache).showsStaleContentNotice)
    }
}
