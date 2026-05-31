import Foundation
import WatchConnectivity

/// iPhone side of the Watch link. Receives quick-action commands from the Watch
/// (guaranteed, ordered, offline-tolerant via `transferUserInfo`), de-duplicates
/// them, and routes them to `QuickLogCoordinator`. Pushes authoritative state back
/// to the Watch via `updateApplicationContext` whenever anything changes.
@MainActor
final class PhoneSessionManager: NSObject {
    private static let processedKey = "watch_processed_cmd_ids"

    private let coordinator: QuickLogCoordinator
    private let appState: AppState
    private let session: WCSession? = WCSession.isSupported() ? .default : nil
    private var processedIDs: [String]

    init(coordinator: QuickLogCoordinator, appState: AppState) {
        self.coordinator = coordinator
        self.appState = appState
        self.processedIDs = UserDefaults.standard.stringArray(forKey: Self.processedKey) ?? []
        super.init()
    }

    func activate() {
        guard let session else { return }
        session.delegate = self
        session.activate()
        NotificationCenter.default.addObserver(
            forName: .widgetDataDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.pushState() }
        }
    }

    func pushState() {
        guard let session, session.activationState == .activated else { return }
        guard let data = try? JSONEncoder().encode(buildState()) else { return }
        try? session.updateApplicationContext([WatchConnectivityKeys.state: data])
    }

    private func buildState() -> WatchState {
        let store = WidgetDataStore.shared

        let feeding: WatchFeedingState
        switch store.feedingState {
        case .idle(let last):
            feeding = .idle(lastFeedingDate: last)
        case .running(let start, let sideRaw):
            feeding = .running(startDate: start, side: FeedingSide(rawValue: sideRaw)?.token ?? "left")
        case .paused(let secs, let sideRaw):
            feeding = .paused(elapsedSeconds: secs, side: FeedingSide(rawValue: sideRaw)?.token ?? "left")
        }

        let sleep: WatchSleepState
        switch store.sleepState {
        case .idle(let dur):    sleep = .idle(lastDurationSeconds: dur)
        case .active(let start): sleep = .active(startDate: start)
        }

        return WatchState(babyName: store.babyName, feeding: feeding, sleep: sleep, diaperCount: store.diaperCount)
    }

    private func process(_ env: WatchCommandEnvelope) {
        guard !processedIDs.contains(env.id.uuidString) else { return }
        processedIDs.append(env.id.uuidString)
        if processedIDs.count > 200 { processedIDs.removeFirst(processedIDs.count - 200) }
        UserDefaults.standard.set(processedIDs, forKey: Self.processedKey)

        switch env.command {
        case .startFeeding(let side): coordinator.startFeeding(sideToken: side)
        case .pauseFeeding:           coordinator.pauseFeeding()
        case .resumeFeeding:          coordinator.resumeFeeding()
        case .stopFeeding:            coordinator.stopFeeding()
        case .startSleep:             coordinator.startSleep()
        case .stopSleep(let quality): coordinator.stopSleep(qualityRaw: quality)
        case .logDiaper:              coordinator.logDiaper()
        }
        pushState()
    }

    nonisolated private func decodeAndProcess(_ payload: [String: Any]) {
        guard let data = payload[WatchConnectivityKeys.command] as? Data,
              let env = try? JSONDecoder().decode(WatchCommandEnvelope.self, from: data) else { return }
        Task { @MainActor [weak self] in self?.process(env) }
    }
}

extension PhoneSessionManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) {
        Task { @MainActor [weak self] in self?.pushState() }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()  // re-activate for the newly-paired Watch
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        decodeAndProcess(userInfo)
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        decodeAndProcess(message)
    }
}
