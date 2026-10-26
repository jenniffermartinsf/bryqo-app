import Foundation

/// The single seam between the app and the network. Abstracted so content loading can be
/// tested with canned responses instead of a real server.
protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

enum HTTPClientError: Error, Equatable {
    /// The response was not HTTP (should not happen with http/https URLs).
    case notHTTP
}

struct URLSessionHTTPClient: HTTPClient {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw HTTPClientError.notHTTP }
        return (data, http)
    }
}
