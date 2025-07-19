import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isOnline = true
    @Published var isOfflineMode = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                self?.updateOfflineMode()
            }
        }
        monitor.start(queue: queue)
    }

    private func updateOfflineMode() {
        print("NetworkMonitor: isOnline = \(isOnline)")
        if !isOnline {
            print("NetworkMonitor: Setting offline mode due to network status")
            isOfflineMode = true
        } else {
            print("NetworkMonitor: Network is online, clearing offline mode")
            isOfflineMode = false
        }
    }

    func setOfflineMode(_ offline: Bool) {
        DispatchQueue.main.async {
            print("NetworkMonitor: setOfflineMode called with \(offline)")
            if offline {
                print("NetworkMonitor: Setting offline mode manually")
                self.isOfflineMode = true
            } else if self.isOnline {
                print("NetworkMonitor: Clearing offline mode manually")
                self.isOfflineMode = false
            } else {
                print("NetworkMonitor: Cannot clear offline mode - network is not online")
            }
        }
    }

    deinit {
        monitor.cancel()
    }
}
