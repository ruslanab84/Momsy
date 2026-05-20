import Foundation

final class LocalFeedingRepository: FeedingRepository {
    private let key = "local_feeding_entries"
    private let calendar = Calendar.current

    private func load() throws -> [FeedingEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([FeedingEntry].self, from: data)
    }

    private func save(_ entries: [FeedingEntry]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(entries), forKey: key)
    }

    func getEntries(for date: Date) async throws -> [FeedingEntry] {
        try load().filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func getEntries(from: Date, to: Date) async throws -> [FeedingEntry] {
        try load().filter { $0.date >= from && $0.date <= to }
    }

    func add(_ entry: FeedingEntry) async throws {
        var entries = try load()
        entries.append(entry)
        try save(entries)
    }

    func delete(id: UUID) async throws {
        var entries = try load()
        entries.removeAll { $0.id == id }
        try save(entries)
    }
}
