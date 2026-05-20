import Foundation

final class LocalMeasurementRepository: MeasurementRepository {
    private let key = "local_measurements"

    private func load() throws -> [MeasurementEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([MeasurementEntry].self, from: data)
    }

    private func save(_ entries: [MeasurementEntry]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(entries), forKey: key)
    }

    func getAll() async throws -> [MeasurementEntry] {
        try load().sorted { $0.date > $1.date }
    }

    func add(_ entry: MeasurementEntry) async throws {
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
