import Network

/// Tells the app when the device goes back online, so work that failed offline can resume
/// at the right moment instead of polling.
nonisolated enum ConnectivityMonitor {
    /// Emits `true` each time the network becomes reachable (and `false` when it is lost).
    /// The monitor stops when the consuming task is cancelled.
    static func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
            continuation.onTermination = { _ in monitor.cancel() }
            monitor.start(queue: DispatchQueue(label: "bryqo.connectivity"))
        }
    }
}
