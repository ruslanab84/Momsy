import Foundation

final class DailyTipRepository {

    private let defaults: UserDefaults
    private let key = "daily_tip_v1"
    private let ttl: TimeInterval = 3 * 3600   // 3 hours

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ tip: DailyTip) {
        guard let data = try? JSONEncoder().encode(tip) else { return }
        defaults.set(data, forKey: key)
    }

    func load() -> DailyTip? {
        guard let data = defaults.data(forKey: key),
              let tip = try? JSONDecoder().decode(DailyTip.self, from: data) else { return nil }
        return tip
    }

    /// Returns true if cached tip exists, has the same contextHash, and is within TTL
    func isFresh(for hash: String) -> Bool {
        guard let tip = load() else { return false }
        let age = -tip.generatedAt.timeIntervalSinceNow
        return tip.contextHash == hash && age < ttl
    }
}
