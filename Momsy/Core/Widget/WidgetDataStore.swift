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

enum WalkWidgetState {
    case idle(lastDurationSeconds: Int?)
    case active(startDate: Date)
}

enum BathWidgetState {
    case idle(lastDurationSeconds: Int?)
    case active(startDate: Date)
}

final class WidgetDataStore {
    static let shared = WidgetDataStore()

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

    func setLastSleepEnd(_ date: Date) {
        defaults.set(date.timeIntervalSinceReferenceDate, forKey: "w_last_sleep_end")
    }

    // MARK: - Walk writes (called from WalkViewModel)

    func setWalkActive(startDate: Date) {
        defaults.set(true, forKey: "w_walk_active")
        defaults.set(startDate.timeIntervalSinceReferenceDate, forKey: "w_walk_start")
        reload()
    }

    func clearWalk(lastDurationSeconds: Int) {
        defaults.set(false, forKey: "w_walk_active")
        defaults.set(lastDurationSeconds, forKey: "w_last_walk_dur")
        reload()
    }

    // MARK: - Bath writes (called from BathViewModel)

    func setBathActive(startDate: Date) {
        defaults.set(true, forKey: "w_bath_active")
        defaults.set(startDate.timeIntervalSinceReferenceDate, forKey: "w_bath_start")
        reload()
    }

    func clearBath(lastDurationSeconds: Int) {
        defaults.set(false, forKey: "w_bath_active")
        defaults.set(lastDurationSeconds, forKey: "w_last_bath_dur")
        reload()
    }

    // MARK: - Baby info writes (called from AppState)

    func setBabyInfo(name: String, birthDate: Date) {
        defaults.set(name, forKey: "w_baby_name")
        defaults.set(birthDate.timeIntervalSinceReferenceDate, forKey: "w_baby_birth")
        reload()
    }

    // MARK: - Diaper writes (called from TodayViewModel)

    func updateDiaperCount(_ count: Int) {
        defaults.set(count, forKey: "w_diaper_count")
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

    var walkState: WalkWidgetState {
        guard defaults.bool(forKey: "w_walk_active") else {
            let dur = defaults.integer(forKey: "w_last_walk_dur")
            return .idle(lastDurationSeconds: dur > 0 ? dur : nil)
        }
        let ti = defaults.double(forKey: "w_walk_start")
        guard ti > 0 else { return .idle(lastDurationSeconds: nil) }
        return .active(startDate: Date(timeIntervalSinceReferenceDate: ti))
    }

    var bathState: BathWidgetState {
        guard defaults.bool(forKey: "w_bath_active") else {
            let dur = defaults.integer(forKey: "w_last_bath_dur")
            return .idle(lastDurationSeconds: dur > 0 ? dur : nil)
        }
        let ti = defaults.double(forKey: "w_bath_start")
        guard ti > 0 else { return .idle(lastDurationSeconds: nil) }
        return .active(startDate: Date(timeIntervalSinceReferenceDate: ti))
    }

    var babyName: String {
        defaults.string(forKey: "w_baby_name") ?? ""
    }

    var babyBirthDate: Date? {
        let ti = defaults.double(forKey: "w_baby_birth")
        guard ti > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: ti)
    }

    var diaperCount: Int {
        defaults.integer(forKey: "w_diaper_count")
    }

    var lastSleepEndDate: Date? {
        let ti = defaults.double(forKey: "w_last_sleep_end")
        guard ti > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: ti)
    }

    // MARK: - Private

    private var idleFeeding: FeedingWidgetState {
        let ti = defaults.double(forKey: "w_last_feeding_date")
        let date = ti > 0 ? Date(timeIntervalSinceReferenceDate: ti) : nil
        return .idle(lastFeedingDate: date)
    }

    private func reload() {
        WidgetCenter.shared.reloadAllTimelines()
        NotificationCenter.default.post(name: .widgetDataDidChange, object: nil)
    }
}

extension Notification.Name {
    /// Posted whenever any tracked state in `WidgetDataStore` changes, so the
    /// Watch link can push fresh state to the paired Apple Watch.
    static let widgetDataDidChange = Notification.Name("WidgetDataStore.didChange")
}
