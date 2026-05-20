import Foundation

final class LocalTemperatureRepository: TemperatureRepository {
    private let key = "local_temperature_log"

    private func load() throws -> [TemperatureEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([TemperatureEntry].self, from: data)
    }

    private func save(_ entries: [TemperatureEntry]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(entries), forKey: key)
    }

    func getAll() async throws -> [TemperatureEntry] {
        try load().sorted { $0.date > $1.date }
    }

    func getEntries(from: Date, to: Date) async throws -> [TemperatureEntry] {
        try load().filter { $0.date >= from && $0.date <= to }
    }

    func add(_ entry: TemperatureEntry) async throws {
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
