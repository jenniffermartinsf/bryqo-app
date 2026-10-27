import Foundation
import Testing
@testable import bryco_app

// MARK: - Test doubles

/// Answers requests with canned responses, in order (the last one repeats), and records them.
final class FakeHTTPClient: HTTPClient, @unchecked Sendable {
    enum Reply {
        case response(status: Int, body: Data = Data(), headers: [String: String] = [:])
        case failure(URLError.Code)
    }

    var replies: [Reply]
    private(set) var requests: [URLRequest] = []

    init(_ reply: Reply) { replies = [reply] }
    init(sequence: [Reply]) { replies = sequence }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        let reply = replies.count > 1 ? replies.removeFirst() : replies[0]
        switch reply {
        case .failure(let code):
            throw URLError(code)
        case .response(let status, let body, let headers):
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
            return (body, response)
        }
    }
}

func encoded(_ catalog: ContentCatalogDTO) -> Data {
    try! JSONEncoder().encode(catalog)
}

func tempCache() -> ContentCache {
    ContentCache(directory: FileManager.default.temporaryDirectory
        .appendingPathComponent("bryqo-content-tests-\(UUID().uuidString)", isDirectory: true))
}

let bundled = BryqoContent.allUnits

/// A small valid catalog: the first bundled unit with an edited title.
func catalog(version: Int, title: String = "Lógica (atualizada)") -> ContentCatalogDTO {
    let unit = bundled[0]
    let edited = LearningUnit(id: unit.id, title: title, subtitle: unit.subtitle, lessons: unit.lessons)
    return ContentCatalogDTO(version: version, content: [edited])
}

// MARK: - Catalog file and mapping

@MainActor
@Suite("Content catalog")
struct ContentCatalogTests {

    /// `content/catalog.json` at the repository root is what the app downloads.
    private var publishedCatalogURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("content/catalog.json")
    }

    @Test("The published catalog matches the content bundled in the app")
    func publishedCatalogMatchesBundled() throws {
        let expected = ContentCatalogDTO(version: ContentRepository.bundledVersion, content: bundled)

        // Regenerate with: TEST_RUNNER_BRYQO_WRITE_CATALOG=1 bundle exec fastlane test
        if ProcessInfo.processInfo.environment["BRYQO_WRITE_CATALOG"] == "1" {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            try FileManager.default.createDirectory(at: publishedCatalogURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try encoder.encode(expected).write(to: publishedCatalogURL)
        }

        let published = try JSONDecoder().decode(ContentCatalogDTO.self, from: Data(contentsOf: publishedCatalogURL))
        #expect(published == expected)
    }

    @Test("Bundled content survives a round trip through the wire format")
    func roundTrip() throws {
        let data = encoded(ContentCatalogDTO(version: 1, content: bundled))
        let decoded = try JSONDecoder().decode(ContentCatalogDTO.self, from: data)

        #expect(decoded.toDomain() == bundled)
    }

    @Test("A question without its exercise drops the lesson, not the unit")
    func brokenLessonIsDropped() throws {
        let unit = bundled[0]
        var dto = ContentCatalogDTO(version: 1, content: [unit])
        var lessons = dto.units[0].lessons
        let first = lessons[0]
        let brokenSteps = first.steps.map { step in
            StepDTO(id: step.id, kind: step.kind, title: step.title, body: step.body,
                    exercise: nil, variableTrace: step.variableTrace, binarySearch: step.binarySearch)
        }
        lessons[0] = LessonDTO(id: first.id, title: first.title, subtitle: first.subtitle,
                               estimatedMinutes: first.estimatedMinutes, xpReward: first.xpReward,
                               materialReward: first.materialReward, steps: brokenSteps)
        dto = ContentCatalogDTO(version: 1, units: [UnitDTO(id: unit.id, title: unit.title, subtitle: unit.subtitle, lessons: lessons)])

        let mapped = try #require(dto.toDomain().first)
        #expect(!mapped.lessons.contains { $0.id == first.id })
        #expect(mapped.lessons.count == unit.lessons.count - 1)
    }

    @Test("Invalid exercises and unknown step kinds are rejected")
    func invalidStepsAreRejected() {
        let wrongAnswer = ExerciseDTO(prompt: "?", options: [OptionDTO(id: "a", text: "A")],
                                      correctOptionIds: ["z"], explanation: "", codeSnippet: nil)
        let stepWithWrongAnswer = StepDTO(id: "s", kind: "singleChoice", title: "", body: "",
                                          exercise: wrongAnswer, variableTrace: nil, binarySearch: nil)
        let futureStep = StepDTO(id: "s", kind: "hologram", title: "", body: "",
                                 exercise: nil, variableTrace: nil, binarySearch: nil)
        let unsortedSearch = StepDTO(id: "s", kind: "binarySearch", title: "", body: "", exercise: nil,
                                     variableTrace: nil, binarySearch: BinarySearchDTO(intro: "", array: [3, 1], target: 1))

        #expect(stepWithWrongAnswer.toDomain() == nil)
        #expect(futureStep.toDomain() == nil)
        #expect(unsortedSearch.toDomain() == nil)
    }
}

// MARK: - HTTP

@MainActor
@Suite("Content service")
struct ContentServiceTests {

    @Test("200 decodes the catalog and keeps the ETag")
    func okResponse() async throws {
        let client = FakeHTTPClient(.response(status: 200, body: encoded(catalog(version: 2)), headers: ["ETag": "\"v2\""]))
        let result = try await ContentService(client: client).fetchCatalog(ifNoneMatch: nil)

        #expect(result == .updated(catalog(version: 2), etag: "\"v2\""))
    }

    @Test("The last ETag is sent, and 304 means nothing to download")
    func notModified() async throws {
        let client = FakeHTTPClient(.response(status: 304))
        let result = try await ContentService(client: client).fetchCatalog(ifNoneMatch: "\"v2\"")

        #expect(result == .notModified)
        #expect(client.requests.first?.value(forHTTPHeaderField: "If-None-Match") == "\"v2\"")
    }

    @Test("Each failure is classified by what to do about it", arguments: [
        (FakeHTTPClient.Reply.response(status: 500), NetworkFailure.server(status: 500)),
        (.response(status: 503), .server(status: 503)),
        (.response(status: 408), .server(status: 408)),
        (.response(status: 429, headers: ["Retry-After": "12"]), .rateLimited(retryAfter: 12)),
        (.response(status: 404), .client(status: 404)),
        (.response(status: 403), .client(status: 403)),
        (.response(status: 200, body: Data("not json".utf8)), .invalidResponse),
        (.failure(.notConnectedToInternet), .offline),
        (.failure(.networkConnectionLost), .offline),
        (.failure(.timedOut), .timeout)
    ])
    func errors(reply: FakeHTTPClient.Reply, expected: NetworkFailure) async {
        await #expect(throws: expected) {
            try await ContentService(client: FakeHTTPClient(reply)).fetchCatalog(ifNoneMatch: nil)
        }
    }
}

// MARK: - Offline-first repository

@MainActor
@Suite("Content repository")
struct ContentRepositoryTests {

    private func makeRepository(_ client: FakeHTTPClient, cache: ContentCache = tempCache()) -> ContentRepository {
        ContentRepository(service: ContentService(client: client), cache: cache, bundled: bundled, bundledVersion: 1,
                          sleep: { _ in }, report: { _ in })
    }

    @Test("Starts with the bundled content before any network call")
    func startsWithBundled() {
        let repository = makeRepository(FakeHTTPClient(.failure(.notConnectedToInternet)))

        #expect(repository.units == bundled)
        #expect(repository.version == 1)
    }

    @Test("A newer catalog replaces the content and is cached for the next launch")
    func newerCatalogIsAppliedAndCached() async {
        let cache = tempCache()
        let client = FakeHTTPClient(.response(status: 200, body: encoded(catalog(version: 2)), headers: ["ETag": "\"v2\""]))

        let repository = makeRepository(client, cache: cache)
        await repository.refresh()

        #expect(repository.version == 2)
        #expect(repository.units.first?.title == "Lógica (atualizada)")

        // Next launch, offline: the cached catalog is used and the ETag is sent.
        let offline = FakeHTTPClient(.failure(.notConnectedToInternet))
        let relaunched = makeRepository(offline, cache: cache)
        #expect(relaunched.units.first?.title == "Lógica (atualizada)")
        await relaunched.refresh()
        #expect(offline.requests.first?.value(forHTTPHeaderField: "If-None-Match") == "\"v2\"")
    }

    @Test("Offline or a broken server keeps the current lessons", arguments: [
        FakeHTTPClient.Reply.failure(.notConnectedToInternet),
        .response(status: 503),
        .response(status: 200, body: Data("{".utf8))
    ])
    func failureKeepsContent(reply: FakeHTTPClient.Reply) async {
        let repository = makeRepository(FakeHTTPClient(reply))
        await repository.refresh()

        #expect(repository.units == bundled)
        #expect(repository.lastFailure != nil)
    }

    @Test("An older catalog, or one with no valid lessons, is ignored")
    func olderOrEmptyCatalogIsIgnored() async {
        let empty = ContentCatalogDTO(version: 9, units: [])
        for body in [encoded(catalog(version: 0)), encoded(empty)] {
            let repository = makeRepository(FakeHTTPClient(.response(status: 200, body: body)))
            await repository.refresh()
            #expect(repository.units == bundled)
        }
    }
}
