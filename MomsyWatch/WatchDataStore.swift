import Foundation
import WidgetKit

/// Watch-local persistence of the latest `WatchState`, shared between the Watch
/// app and its complication widget extension via the watch app group.
/// Mirror of the iOS `WidgetDataStore` pattern.
///
/// Target membership: MomsyWatch app **and** MomsyWatchWidget extension.
final class WatchDataStore {
    static let shared = WatchDataStore()

    private static let key = "watch_state_v1"
    private let defaults: UserDefaults

    private init() {
        defaults = UserDefaults(suiteName: "group.RuslanAbd.Momsy.watch") ?? .standard
    }

    func save(_ state: WatchState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: Self.key)
        WidgetCenter.shared.reloadAllTimelines()
    }

    var state: WatchState {
        guard let data = defaults.data(forKey: Self.key),
              let state = try? JSONDecoder().decode(WatchState.self, from: data) else {
            return .empty
        }
        return state
    }
}

extension WatchState {
    /// Most recent feeding timestamp usable by the "time since last feeding"
    /// complication, regardless of whether a session is idle / running / paused.
    var lastFeedingDate: Date? {
        switch feeding {
        case .idle(let date):       return date
        case .running(let start, _): return start
        case .paused:               return nil
        }
    }

    var activeFeedingStart: Date? {
        if case .running(let start, _) = feeding { return start }
        return nil
    }

    var activeSleepStart: Date? {
        if case .active(let start) = sleep { return start }
        return nil
    }
}
