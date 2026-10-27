import Foundation

/// What went wrong with a network call, in the terms that matter for deciding what to do next:
/// should we try again, and does anyone need to know?
nonisolated enum NetworkFailure: Error, Equatable, Sendable {
    /// No connection. Retrying now is pointless; wait for the connection to come back.
    case offline
    /// The request took too long. Probably transient.
    case timeout
    /// 5xx, 408 or another transient server problem.
    case server(status: Int)
    /// 429: the server asked us to slow down, optionally saying for how long.
    case rateLimited(retryAfter: TimeInterval?)
    /// 4xx: the request itself is wrong (missing file, permission). Retrying cannot fix it.
    case client(status: Int)
    /// The body could not be decoded. The same bytes will fail the same way.
    case invalidResponse

    /// Worth an immediate retry with backoff.
    var isRetryable: Bool {
        switch self {
        case .timeout, .server, .rateLimited: true
        case .offline, .client, .invalidResponse: false
        }
    }

    /// Something only the team can fix, so it is reported instead of shown to the user.
    var needsReporting: Bool {
        switch self {
        case .client, .invalidResponse, .server, .rateLimited: true
        case .offline, .timeout: false
        }
    }

    /// Short identifier for logs and crash reports.
    var code: String {
        switch self {
        case .offline: "offline"
        case .timeout: "timeout"
        case .server(let status): "server_\(status)"
        case .rateLimited: "rate_limited"
        case .client(let status): "client_\(status)"
        case .invalidResponse: "invalid_response"
        }
    }

    static func from(status: Int, retryAfter: TimeInterval?) -> NetworkFailure {
        switch status {
        case 429: .rateLimited(retryAfter: retryAfter)
        case 408: .server(status: status)
        case 400..<500: .client(status: status)
        default: .server(status: status)
        }
    }

    static func from(urlError code: URLError.Code) -> NetworkFailure {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed,
             .internationalRoamingOff, .callIsActive:
            .offline
        case .timedOut:
            .timeout
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            .server(status: 0)
        case .badServerResponse, .cannotParseResponse, .cannotDecodeContentData, .cannotDecodeRawData:
            .invalidResponse
        default:
            .server(status: 0)
        }
    }

    /// Parses `Retry-After` given in seconds (the HTTP-date form is ignored).
    static func retryAfter(header: String?) -> TimeInterval? {
        guard let header, let seconds = TimeInterval(header.trimmingCharacters(in: .whitespaces)),
              seconds >= 0 else { return nil }
        return seconds
    }
}

/// Exponential backoff with jitter, so thousands of devices don't retry in the same instant.
nonisolated struct RetryPolicy: Sendable {
    var maxAttempts = 3
    var baseDelay: TimeInterval = 1
    var maxDelay: TimeInterval = 30
    /// Random factor applied to each delay; injectable so tests are deterministic.
    var jitter: @Sendable () -> Double = { Double.random(in: 0.8...1.2) }

    /// Delay before retry number `attempt` (1 = first retry): 1 s, 2 s, 4 s… with jitter,
    /// or the server's Retry-After when it sent one. Always capped at `maxDelay`.
    func delay(beforeRetry attempt: Int, retryAfter: TimeInterval? = nil) -> TimeInterval {
        if let retryAfter { return min(retryAfter, maxDelay) }
        let exponential = baseDelay * pow(2, Double(attempt - 1))
        return min(exponential * jitter(), maxDelay)
    }
}
