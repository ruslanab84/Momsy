import Foundation

final class LocalSleepRepository: SleepRepository {
    private let key = "local_sleep_entries"

    private func load() throws -> [SleepEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([SleepEntry].self, from: data)
    }

    private func save(_ entries: [SleepEntry]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(entries), forKey: key)
    }

    func getEntries(from: Date, to: Date) async throws -> [SleepEntry] {
        try load().filter { $0.startDate >= from && $0.startDate <= to }
    }

    func add(_ entry: SleepEntry) async throws {
        var entries = try load()
        entries.append(entry)
        try save(entries)
    }

    func update(_ entry: SleepEntry) async throws {
        var entries = try load()
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) { entries[idx] = entry }
        try save(entries)
    }

    func delete(id: UUID) async throws {
        var entries = try load()
        entries.removeAll { $0.id == id }
        try save(entries)
    }
}
