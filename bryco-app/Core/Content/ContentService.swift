import Foundation

/// What fetching the remote catalog produced.
enum ContentFetchResult: Equatable {
    /// A new catalog arrived (status 200), with its ETag for the next request.
    case updated(ContentCatalogDTO, etag: String?)
    /// The server confirmed nothing changed since `etag` (status 304).
    case notModified
}


/// Downloads the lesson catalog. Pure request/response handling; caching and fallback live in
/// `ContentRepository`.
struct ContentService {
    static let catalogURL = URL(string: "https://raw.githubusercontent.com/jenniffermartinsf/bryqo-app/main/content/catalog.json")!

    let client: any HTTPClient
    var url: URL = ContentService.catalogURL
    var timeout: TimeInterval = 10

    func fetchCatalog(ifNoneMatch etag: String?) async throws(NetworkFailure) -> ContentFetchResult {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.data(for: request)
        } catch let error as URLError {
            throw .from(urlError: error.code)
        } catch {
            throw .server(status: 0)
        }

        switch response.statusCode {
        case 200:
            do {
                let catalog = try JSONDecoder().decode(ContentCatalogDTO.self, from: data)
                return .updated(catalog, etag: response.value(forHTTPHeaderField: "ETag"))
            } catch {
                throw .invalidResponse
            }
        case 304:
            return .notModified
        default:
            throw .from(
                status: response.statusCode,
                retryAfter: NetworkFailure.retryAfter(header: response.value(forHTTPHeaderField: "Retry-After"))
            )
        }
    }
}
