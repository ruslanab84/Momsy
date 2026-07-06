import Foundation

final class LocalLeapCheckInRepository: LeapCheckInRepository {
    private let defaults: UserDefaults
    private let calendar: Calendar
    private let keyPrefix = "local_leap_check_ins"

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
    }

    func getCheckIns(leapID: Int) async throws -> [LeapDailyCheckIn] {
        try load(leapID: leapID)
    }

    func saveCheckIn(_ checkIn: LeapDailyCheckIn) async throws {
        let normalized = LeapDailyCheckIn(
            leapID: checkIn.leapID,
            date: calendar.startOfDay(for: checkIn.date),
            symptoms: checkIn.symptoms
        )
        var items = try load(leapID: normalized.leapID)
        if let index = items.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: normalized.date) }) {
            if normalized.symptoms.isEmpty {
                items.remove(at: index)
            } else {
                items[index] = normalized
            }
        } else if !normalized.symptoms.isEmpty {
            items.append(normalized)
        }
        try save(items.sorted { $0.date < $1.date }, leapID: normalized.leapID)
    }

    private func load(leapID: Int) throws -> [LeapDailyCheckIn] {
        guard let data = defaults.data(forKey: key(leapID: leapID)) else { return [] }
        return try JSONDecoder().decode([LeapDailyCheckIn].self, from: data)
    }

    private func save(_ items: [LeapDailyCheckIn], leapID: Int) throws {
        defaults.set(try JSONEncoder().encode(items), forKey: key(leapID: leapID))
    }

    private func key(leapID: Int) -> String {
        "\(keyPrefix)_\(ActiveBaby.scope.uuidString)_\(leapID)"
    }
}
