import Foundation
import WidgetKit

enum FeedingWidgetState {
    case idle(lastFeedingDate: Date?)
    case running(effectiveStartDate: Date, side: String)
    case paused(elapsedSeconds: Int, side: String)
}

enum SleepWidgetState {
    case idle(lastDurationSeconds: Int?)
    case active(startDate: Date)
}

final class WidgetDataStore {
    static let shared = WidgetDataStore()

    static let widgetKind = "MomsyFeedSleepWidget"

    private let defaults: UserDefaults

    private init() {
        defaults = UserDefaults(suiteName: "group.RuslanAbd.Momsy") ?? .standard
    }

    // MARK: - Feeding writes (called from FeedingViewModel)

    func setFeedingRunning(effectiveStartDate: Date, side: String) {
        defaults.set("running", forKey: "w_feeding_state")
        defaults.set(effectiveStartDate.timeIntervalSinceReferenceDate, forKey: "w_feeding_eff_start")
        defaults.set(side, forKey: "w_feeding_side")
        reload()
    }

    func setFeedingPaused(elapsedSeconds: Int, side: String) {
        defaults.set("paused", forKey: "w_feeding_state")
        defaults.set(elapsedSeconds, forKey: "w_feeding_paused_sec")
        defaults.set(side, forKey: "w_feeding_side")
        reload()
    }

    func clearFeeding(lastFeedingDate: Date) {
        defaults.set("idle", forKey: "w_feeding_state")
        defaults.set(lastFeedingDate.timeIntervalSinceReferenceDate, forKey: "w_last_feeding_date")
        reload()
    }

    // MARK: - Sleep writes (called from SleepViewModel)

    func setSleepActive(startDate: Date) {
        defaults.set(true, forKey: "w_sleep_active")
        defaults.set(startDate.timeIntervalSinceReferenceDate, forKey: "w_sleep_start")
        reload()
    }

    func clearSleep(lastDurationSeconds: Int) {
        defaults.set(false, forKey: "w_sleep_active")
        defaults.set(lastDurationSeconds, forKey: "w_last_sleep_dur")
        reload()
    }

    // MARK: - Reads (called from MomsyWidgetProvider)

    var feedingState: FeedingWidgetState {
        let raw = defaults.string(forKey: "w_feeding_state") ?? "idle"
        let side = defaults.string(forKey: "w_feeding_side") ?? ""
        switch raw {
        case "running":
            let ti = defaults.double(forKey: "w_feeding_eff_start")
            guard ti > 0 else { return idleFeeding }
            return .running(effectiveStartDate: Date(timeIntervalSinceReferenceDate: ti), side: side)
        case "paused":
            let secs = defaults.integer(forKey: "w_feeding_paused_sec")
            return .paused(elapsedSeconds: secs, side: side)
        default:
            return idleFeeding
        }
    }

    var sleepState: SleepWidgetState {
        guard defaults.bool(forKey: "w_sleep_active") else {
            let dur = defaults.integer(forKey: "w_last_sleep_dur")
            return .idle(lastDurationSeconds: dur > 0 ? dur : nil)
        }
        let ti = defaults.double(forKey: "w_sleep_start")
        guard ti > 0 else { return .idle(lastDurationSeconds: nil) }
        return .active(startDate: Date(timeIntervalSinceReferenceDate: ti))
    }

    // MARK: - Private

    private var idleFeeding: FeedingWidgetState {
        let ti = defaults.double(forKey: "w_last_feeding_date")
        let date = ti > 0 ? Date(timeIntervalSinceReferenceDate: ti) : nil
        return .idle(lastFeedingDate: date)
    }

    private func reload() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetDataStore.widgetKind)
    }
}
