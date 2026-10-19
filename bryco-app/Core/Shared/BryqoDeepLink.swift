import Foundation

/// URLs the app can be opened with, e.g. from the streak widget.
///
/// **This file must belong to BOTH targets** (app + widget): the widget builds the URL and
/// the app parses it, so both sides share one definition.
enum BryqoDeepLink: String, CaseIterable {
    case learn
    case review

    static let scheme = "bryqo"

    init?(url: URL) {
        guard url.scheme == Self.scheme, let host = url.host() else { return nil }
        self.init(rawValue: host)
    }

    var url: URL {
        URL(string: "\(Self.scheme)://\(rawValue)")!
    }
}
