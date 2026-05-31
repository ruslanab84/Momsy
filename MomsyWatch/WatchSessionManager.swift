import Foundation
import WatchConnectivity
import WatchKit

/// Watch side of the link. Sends quick-action commands to the iPhone via
/// `transferUserInfo` (guaranteed, ordered, offline-tolerant), applies optimistic
/// local state for snappy UI, and ingests authoritative state from the iPhone via
/// `didReceiveApplicationContext`.
@MainActor
final class WatchSessionManager: NSObject, ObservableObject {
    @Published private(set) var state: WatchState = WatchDataStore.shared.state

    private let session: WCSession? = WCSession.isSupported() ? .default : nil

    func activate() {
        guard let session else { return }
        session.delegate = self
        session.activate()
    }

    var isReachable: Bool { session?.isReachable ?? false }

    // MARK: - Sending commands

    func send(_ command: WatchCommand, haptic: WKHapticType = .click) {
        applyOptimistic(command)
        WKInterfaceDevice.current().play(haptic)
        guard let session,
              let data = try? JSONEncoder().encode(WatchCommandEnvelope(command)) else { return }
        // transferUserInfo queues and delivers in the background even when the
        // iPhone isn't currently reachable — guaranteed FIFO delivery.
        session.transferUserInfo([WatchConnectivityKeys.command: data])
    }

    private func applyOptimistic(_ command: WatchCommand) {
        switch command {
        case .startFeeding(let side):
            state.feeding = .running(startDate: Date(), side: side)
        case .pauseFeeding:
            if case .running(let start, let side) = state.feeding {
                state.feeding = .paused(elapsedSeconds: max(0, Int(Date().timeIntervalSince(start))), side: side)
            }
        case .resumeFeeding:
            if case .paused(let secs, let side) = state.feeding {
                state.feeding = .running(startDate: Date().addingTimeInterval(-TimeInterval(secs)), side: side)
            }
        case .stopFeeding:
            state.feeding = .idle(lastFeedingDate: Date())
        case .startSleep:
            state.sleep = .active(startDate: Date())
        case .stopSleep:
            state.sleep = .idle(lastDurationSeconds: nil)
        case .logDiaper:
            state.diaperCount += 1
        }
        WatchDataStore.shared.save(state)
    }

    private func apply(_ newState: WatchState) {
        state = newState
        WatchDataStore.shared.save(newState)
    }
}

extension WatchSessionManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext[WatchConnectivityKeys.state] as? Data,
              let newState = try? JSONDecoder().decode(WatchState.self, from: data) else { return }
        Task { @MainActor [weak self] in self?.apply(newState) }
    }
}
