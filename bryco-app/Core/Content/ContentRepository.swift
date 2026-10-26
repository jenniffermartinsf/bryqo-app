import Foundation
import Observation

/// Where the app's lessons come from. Offline-first: it starts with what is already on the
/// device and only replaces it when a valid, newer catalog arrives from the network.
///
/// Order of preference: cached remote catalog → content bundled in the app. A refresh never
/// blocks the UI and never makes content disappear: any failure keeps the current lessons.
@Observable
final class ContentRepository {
    /// Version of the content compiled into the app (`BryqoContent`).
    static let bundledVersion = 1

    private(set) var units: [LearningUnit]
    private(set) var version: Int
    private(set) var lastRefreshError: ContentFetchError?

    @ObservationIgnored private let service: ContentService
    @ObservationIgnored private let cache: ContentCache
    @ObservationIgnored private var isRefreshing = false

    init(
        service: ContentService = ContentService(client: URLSessionHTTPClient()),
        cache: ContentCache = .applicationSupport,
        bundled: [LearningUnit] = BryqoContent.allUnits,
        bundledVersion: Int = ContentRepository.bundledVersion
    ) {
        self.service = service
        self.cache = cache
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

    /// Asks the server for a newer catalog. Safe to call often: it sends the last ETag, so an
    /// unchanged catalog costs one tiny 304 response.
    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            switch try await service.fetchCatalog(ifNoneMatch: cache.etag) {
            case .notModified:
                lastRefreshError = nil
            case .updated(let catalog, let etag):
                lastRefreshError = nil
                // Never go back to older content, and never replace lessons with nothing.
                let mapped = catalog.toDomain()
                guard catalog.version >= version, !mapped.isEmpty else { return }
                cache.save(catalog, etag: etag)
                units = mapped
                version = catalog.version
            }
        } catch {
            // Offline, server down or broken JSON: keep showing what we have.
            lastRefreshError = error
        }
    }
}

/// The last valid remote catalog and its ETag, kept on disk for offline launches.
struct ContentCache {
    let directory: URL

    static var applicationSupport: ContentCache {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return ContentCache(directory: base.appendingPathComponent("RemoteContent", isDirectory: true))
    }

    private var catalogURL: URL { directory.appendingPathComponent("catalog.json") }
    private var etagURL: URL { directory.appendingPathComponent("catalog.etag") }

    var etag: String? {
        try? String(contentsOf: etagURL, encoding: .utf8)
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
}
