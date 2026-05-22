import Foundation

final class LocalWalkRepository: WalkRepository {
    private let key = "walk_entries_v1"

    func start() async throws -> WalkEntry {
        let entry = WalkEntry(startDate: Date())
        var all = load()
        all.append(entry)
        persist(all)
        return entry
    }

    func stop(_ entry: WalkEntry) async throws -> WalkEntry {
        var finished = entry
        finished.endDate = Date()
        var all = load()
        if let idx = all.firstIndex(where: { $0.id == entry.id }) {
            all[idx] = finished
        }
        persist(all)
        return finished
    }

    func getEntries(from: Date, to: Date) async throws -> [WalkEntry] {
        load().filter { $0.startDate >= from && $0.startDate < to }
    }

    private func load() -> [WalkEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([WalkEntry].self, from: data)
        else { return [] }
        return entries
    }

    private func persist(_ entries: [WalkEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
