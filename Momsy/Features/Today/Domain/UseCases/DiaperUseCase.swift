import Foundation

final class DiaperUseCase {
    private let countKey = "diaper_today_count"
    private let dateKey  = "diaper_today_date"

    var count: Int {
        guard let saved = UserDefaults.standard.object(forKey: dateKey) as? Date,
              Calendar.current.isDateInToday(saved) else { return 0 }
        return UserDefaults.standard.integer(forKey: countKey)
    }

    @discardableResult
    func increment() -> Int {
        let new = count + 1
        persist(new)
        return new
    }

    @discardableResult
    func decrement() -> Int {
        let new = max(0, count - 1)
        persist(new)
        return new
    }

    private func persist(_ value: Int) {
        UserDefaults.standard.set(value, forKey: countKey)
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }
}
