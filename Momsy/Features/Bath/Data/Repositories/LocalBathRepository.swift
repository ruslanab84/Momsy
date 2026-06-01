import Foundation

final class LocalBathRepository: BathRepository {
    private let key = "bath_entries_v1"

    func start() async throws -> BathEntry {
        let entry = BathEntry(startDate: Date())
        var all = load()
        all.append(entry)
        persist(all)
        return entry
    }

    func stop(_ entry: BathEntry) async throws -> BathEntry {
        var finished = entry
        finished.endDate = Date()
        var all = load()
        if let idx = all.firstIndex(where: { $0.id == entry.id }) {
            all[idx] = finished
        }
        persist(all)
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [BathEntry] {
        load().filter { $0.startDate >= from && $0.startDate < to }
    }

    func add(_ entry: BathEntry) async throws {
        var all = load()
        all.append(entry)
        persist(all)
    }

    func upsert(_ entries: [BathEntry]) async throws {
        guard !entries.isEmpty else { return }
        var all = load()
        let existing = Set(all.map(\.id))
        var changed = false
        for entry in entries where !existing.contains(entry.id) {
            all.append(entry)
            changed = true
        }
        if changed { persist(all) }
    }

    private func load() -> [BathEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([BathEntry].self, from: data)
        else { return [] }
        return entries
    }

    private func persist(_ entries: [BathEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
