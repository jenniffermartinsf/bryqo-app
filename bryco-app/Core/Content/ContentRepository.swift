import Foundation
import Observation

/// A content problem worth telling the team about (never shown to the user).
nonisolated enum ContentIssue: Equatable, Sendable {
    /// The fetch failed for a reason only the team can fix, after `attempts` tries.
    case fetchFailed(NetworkFailure, attempts: Int)
    /// The catalog decoded, but these lessons were invalid and dropped.
    case lessonsDropped([String])

    var code: String {
        switch self {
        case .fetchFailed(let failure, _): "fetch_\(failure.code)"
        case .lessonsDropped: "lessons_dropped"
        }
    }

    var details: String {
        switch self {
        case .fetchFailed(let failure, let attempts): "\(failure.code) after \(attempts) attempt(s)"
        case .lessonsDropped(let ids): "\(ids.count) lesson(s) dropped: \(ids.joined(separator: ", "))"
        }
    }
}

/// Where the app's lessons come from. Offline-first: it starts with what is already on the
/// device and only replaces it when a valid, newer catalog arrives from the network.
///
/// Failures are handled by kind, never shown as "error loading":
/// - offline: no retry now; `connectionRestored()` fetches again when the network is back
/// - timeout, 5xx, 429: retried with exponential backoff (and Retry-After)
/// - 4xx, invalid JSON: not retried; reported to the team, like dropped lessons
@Observable
final class ContentRepository {
    /// Version of the content compiled into the app (`BryqoContent`).
    static let bundledVersion = 1
    /// How long without reaching the server before the user is told content may be outdated.
    static let staleAfter: TimeInterval = 7 * 24 * 60 * 60

    private(set) var units: [LearningUnit]
    private(set) var version: Int
    private(set) var lastFailure: NetworkFailure?
    /// True after an offline failure, until the connection returns and a refresh succeeds.
    private(set) var isWaitingForConnection = false
    private(set) var lastSuccessfulCheck: Date?

    @ObservationIgnored private let service: ContentService
    @ObservationIgnored private let cache: ContentCache
    @ObservationIgnored private let retryPolicy: RetryPolicy
    @ObservationIgnored private let sleep: @Sendable (TimeInterval) async throws -> Void
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let report: (ContentIssue) -> Void
    @ObservationIgnored private let firstLaunch: Date
    @ObservationIgnored private var isRefreshing = false

    init(
        service: ContentService = ContentService(client: URLSessionHTTPClient()),
        cache: ContentCache = .applicationSupport,
        bundled: [LearningUnit] = BryqoContent.allUnits,
        bundledVersion: Int = ContentRepository.bundledVersion,
        retryPolicy: RetryPolicy = RetryPolicy(),
        sleep: @escaping @Sendable (TimeInterval) async throws -> Void = { try await Task.sleep(for: .seconds($0)) },
        now: @escaping () -> Date = Date.init,
        report: @escaping (ContentIssue) -> Void = BryqoAnalytics.recordContentIssue
    ) {
        self.service = service
        self.cache = cache
        self.retryPolicy = retryPolicy
        self.sleep = sleep
        self.now = now
        self.report = report
        self.firstLaunch = cache.firstLaunch(default: now())
        self.lastSuccessfulCheck = cache.lastSuccessfulCheck

        if let cached = cache.loadCatalog(), cached.version >= bundledVersion {
            let mapped = cached.toDomain()
            if !mapped.isEmpty {
                units = mapped
                version = cached.version
                return
            }
        }
        units = bundled
        version = bundledVersion
    }

    func lesson(for id: String) -> Lesson? {
        for unit in units {
            if let lesson = unit.lessons.first(where: { $0.id == id }) { return lesson }
        }
        return nil
    }

    /// True when the server hasn't been reached for a week: the only failure the user sees,
    /// as a gentle hint that new lessons need a connection.
    var showsStaleContentNotice: Bool {
        now().timeIntervalSince(lastSuccessfulCheck ?? firstLaunch) > Self.staleAfter
    }

    /// Asks the server for a newer catalog, retrying transient failures. Safe to call often:
    /// it sends the last ETag, so an unchanged catalog costs one tiny 304 response.
    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        var attempt = 1
        while true {
            do {
                let result = try await service.fetchCatalog(ifNoneMatch: cache.etag)
                apply(result)
                return
            } catch {
                lastFailure = error
                if error == .offline {
                    isWaitingForConnection = true
                    return
                }
                guard error.isRetryable, attempt < retryPolicy.maxAttempts, !Task.isCancelled else {
                    if error.needsReporting {
                        report(.fetchFailed(error, attempts: attempt))
                    }
                    return
                }
                let retryAfter: TimeInterval? = if case .rateLimited(let seconds) = error { seconds } else { nil }
                do {
                    try await sleep(retryPolicy.delay(beforeRetry: attempt, retryAfter: retryAfter))
                } catch {
                    return   // cancelled while waiting
                }
                attempt += 1
            }
        }
    }

    /// Called when the device goes back online. Refreshes only if an offline failure left
    /// the content waiting, so a flapping connection doesn't trigger extra requests.
    func connectionRestored() async {
        guard isWaitingForConnection else { return }
        await refresh()
    }

    private func apply(_ result: ContentFetchResult) {
        lastFailure = nil
        isWaitingForConnection = false
        let checkedAt = now()
        lastSuccessfulCheck = checkedAt
        cache.saveLastSuccessfulCheck(checkedAt)

        guard case .updated(let catalog, let etag) = result else { return }
        let (mapped, dropped) = catalog.mapped()
        if !dropped.isEmpty {
            report(.lessonsDropped(dropped))
        }
        // Never go back to older content, and never replace lessons with nothing.
        guard catalog.version >= version, !mapped.isEmpty else { return }
        cache.save(catalog, etag: etag)
        units = mapped
        version = catalog.version
    }
}

/// The last valid remote catalog, its ETag and check dates, kept on disk for offline launches.
struct ContentCache {
    let directory: URL

    static var applicationSupport: ContentCache {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return ContentCache(directory: base.appendingPathComponent("RemoteContent", isDirectory: true))
    }

    private var catalogURL: URL { directory.appendingPathComponent("catalog.json") }
    private var etagURL: URL { directory.appendingPathComponent("catalog.etag") }
    private var lastCheckURL: URL { directory.appendingPathComponent("last-check") }
    private var firstLaunchURL: URL { directory.appendingPathComponent("first-launch") }

    var etag: String? {
        try? String(contentsOf: etagURL, encoding: .utf8)
    }

    var lastSuccessfulCheck: Date? { readDate(lastCheckURL) }

    /// The first time content was loaded on this device; written once.
    func firstLaunch(default date: Date) -> Date {
        if let stored = readDate(firstLaunchURL) { return stored }
        writeDate(date, to: firstLaunchURL)
        return date
    }

    func saveLastSuccessfulCheck(_ date: Date) {
        writeDate(date, to: lastCheckURL)
    }

    func loadCatalog() -> ContentCatalogDTO? {
        guard let data = try? Data(contentsOf: catalogURL) else { return nil }
        return try? JSONDecoder().decode(ContentCatalogDTO.self, from: data)
    }

    func save(_ catalog: ContentCatalogDTO, etag: String?) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try JSONEncoder().encode(catalog).write(to: catalogURL, options: .atomic)
            if let etag {
                try etag.write(to: etagURL, atomically: true, encoding: .utf8)
            } else {
                try? FileManager.default.removeItem(at: etagURL)
            }
        } catch {
            // A failed cache write only means the next launch uses older content.
        }
    }

    private func readDate(_ url: URL) -> Date? {
        guard let text = try? String(contentsOf: url, encoding: .utf8),
              let seconds = TimeInterval(text.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        return Date(timeIntervalSince1970: seconds)
    }

    private func writeDate(_ date: Date, to url: URL) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? String(date.timeIntervalSince1970).write(to: url, atomically: true, encoding: .utf8)
    }
}
