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
    private var reloadTask: Task<Void, Never>?

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

    func setSleepActive(startDate: Date, babyId: UUID? = nil) {
        defaults.set(true, forKey: sleepActiveKey(for: babyId))
        defaults.set(startDate.timeIntervalSinceReferenceDate, forKey: sleepStartKey(for: babyId))
        if let babyId {
            defaults.set(babyId.uuidString, forKey: "w_sleep_active_baby_id")
        }
        defaults.set(true, forKey: "w_sleep_active")
        defaults.set(startDate.timeIntervalSinceReferenceDate, forKey: "w_sleep_start")
        reload()
    }

    func clearSleep(lastDurationSeconds: Int, babyId: UUID? = nil) {
        let startKey = sleepStartKey(for: babyId)
        let startTime = defaults.double(forKey: startKey)

        defaults.set(false, forKey: sleepActiveKey(for: babyId))
        defaults.set(lastDurationSeconds, forKey: sleepDurationKey(for: babyId))
        if startTime > 0 {
            defaults.set(startTime, forKey: sleepLastStartKey(for: babyId))
        }

        if babyId == nil || sleepActiveBabyId == nil || sleepActiveBabyId == babyId {
            defaults.set(false, forKey: "w_sleep_active")
            defaults.set(lastDurationSeconds, forKey: "w_last_sleep_dur")
            if startTime > 0 {
                defaults.set(startTime, forKey: "w_last_sleep_start")
            }
            defaults.removeObject(forKey: "w_sleep_active_baby_id")
        }
        reload()
    }

    func setLastSleepEnd(_ date: Date, babyId: UUID? = nil) {
        defaults.set(date.timeIntervalSinceReferenceDate, forKey: sleepEndKey(for: babyId))
        if let babyId {
            defaults.set(babyId.uuidString, forKey: "w_last_sleep_end_baby_id")
        } else {
            defaults.removeObject(forKey: "w_last_sleep_end_baby_id")
        }
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

    func setBabyInfo(id: UUID?, name: String, birthDate: Date) {
        if let id {
            defaults.set(id.uuidString, forKey: "w_baby_id")
        }
        defaults.set(name, forKey: "w_baby_name")
        defaults.set(birthDate.timeIntervalSinceReferenceDate, forKey: "w_baby_birth")
        reload()
    }

    func setBabyInfo(name: String, birthDate: Date) {
        setBabyInfo(id: currentBabyId, name: name, birthDate: birthDate)
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
        sleepState(for: currentBabyId)
    }

    func sleepState(for babyId: UUID?) -> SleepWidgetState {
        let activeKey = sleepActiveKey(for: babyId)
        let hasScopedState = babyId != nil && defaults.object(forKey: activeKey) != nil
        if hasScopedState || babyId == nil {
            return sleepState(activeKey: activeKey, startKey: sleepStartKey(for: babyId), durationKey: sleepDurationKey(for: babyId))
        }
        if let sleepActiveBabyId, sleepActiveBabyId != babyId {
            let dur = defaults.integer(forKey: sleepDurationKey(for: babyId))
            return .idle(lastDurationSeconds: dur > 0 ? dur : nil)
        }
        return sleepState(activeKey: "w_sleep_active", startKey: "w_sleep_start", durationKey: "w_last_sleep_dur")
    }

    private func sleepState(activeKey: String, startKey: String, durationKey: String) -> SleepWidgetState {
        guard defaults.bool(forKey: activeKey) else {
            let dur = defaults.integer(forKey: durationKey)
            return .idle(lastDurationSeconds: dur > 0 ? dur : nil)
        }
        let ti = defaults.double(forKey: startKey)
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

    var currentBabyId: UUID? {
        defaults.string(forKey: "w_baby_id").flatMap(UUID.init)
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
        lastSleepEndDate(for: currentBabyId)
    }

    func lastSleepEndDate(for babyId: UUID?) -> Date? {
        let key = sleepEndKey(for: babyId)
        let scopedValue = defaults.double(forKey: key)
        let fallbackValue: Double
        if babyId == nil || lastSleepEndBabyId == nil || lastSleepEndBabyId == babyId {
            fallbackValue = defaults.double(forKey: "w_last_sleep_end")
        } else {
            fallbackValue = 0
        }
        let ti = scopedValue > 0 ? scopedValue : fallbackValue
        guard ti > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: ti)
    }

    var lastSleepStartDate: Date? {
        lastSleepStartDate(for: currentBabyId)
    }

    func lastSleepStartDate(for babyId: UUID?) -> Date? {
        let key = sleepLastStartKey(for: babyId)
        let scopedValue = defaults.double(forKey: key)
        let fallbackValue: Double
        if babyId == nil || lastSleepEndBabyId == nil || lastSleepEndBabyId == babyId {
            fallbackValue = defaults.double(forKey: "w_last_sleep_start")
        } else {
            fallbackValue = 0
        }
        let ti = scopedValue > 0 ? scopedValue : fallbackValue
        guard ti > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: ti)
    }

    func clearAll() {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("w_") {
            defaults.removeObject(forKey: key)
        }
        reload()
    }

    // MARK: - Private

    private var idleFeeding: FeedingWidgetState {
        let ti = defaults.double(forKey: "w_last_feeding_date")
        let date = ti > 0 ? Date(timeIntervalSinceReferenceDate: ti) : nil
        return .idle(lastFeedingDate: date)
    }

    private var sleepActiveBabyId: UUID? {
        defaults.string(forKey: "w_sleep_active_baby_id").flatMap(UUID.init)
    }

    private var lastSleepEndBabyId: UUID? {
        defaults.string(forKey: "w_last_sleep_end_baby_id").flatMap(UUID.init)
    }

    private func scopedSleepKey(_ base: String, for babyId: UUID?) -> String {
        guard let babyId else { return base }
        return "\(base)_\(babyId.uuidString)"
    }

    private func sleepActiveKey(for babyId: UUID?) -> String {
        scopedSleepKey("w_sleep_active", for: babyId)
    }

    private func sleepStartKey(for babyId: UUID?) -> String {
        scopedSleepKey("w_sleep_start", for: babyId)
    }

    private func sleepDurationKey(for babyId: UUID?) -> String {
        scopedSleepKey("w_last_sleep_dur", for: babyId)
    }

    private func sleepLastStartKey(for babyId: UUID?) -> String {
        scopedSleepKey("w_last_sleep_start", for: babyId)
    }

    private func sleepEndKey(for babyId: UUID?) -> String {
        scopedSleepKey("w_last_sleep_end", for: babyId)
    }

    private func reload() {
        reloadTask?.cancel()
        reloadTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                WidgetCenter.shared.reloadAllTimelines()
                NotificationCenter.default.post(name: .widgetDataDidChange, object: nil)
            }
        }
    }
}

extension Notification.Name {
    /// Posted whenever any tracked state in `WidgetDataStore` changes, so the
    /// Watch link can push fresh state to the paired Apple Watch.
    static let widgetDataDidChange = Notification.Name("WidgetDataStore.didChange")
}
