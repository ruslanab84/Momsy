import Foundation

struct QuickLogEntry: Codable {
    let id: UUID
    let time: Date
    let kind: BlobKind
    let label: String
}

final class QuickLogRepository {
    // Scoped per active child so switching the active baby never leaks the previous
    // child's quick events into "Today so far". `ActiveBaby.scope` is read at access
    // time, mirroring the query-time scoping used by the SwiftData repositories.
    private var key: String     { "quick_log_today_entries_\(ActiveBaby.scope.uuidString)" }
    private var dateKey: String { "quick_log_today_date_\(ActiveBaby.scope.uuidString)" }

    func load() -> [QuickLogEntry] {
        guard let saved = UserDefaults.standard.object(forKey: dateKey) as? Date,
              Calendar.current.isDateInToday(saved),
              let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([QuickLogEntry].self, from: data)
        else { return [] }
        return entries
    }

    func append(_ entry: QuickLogEntry) {
        var current = load()
        current.insert(entry, at: 0)
        persist(current)
    }

    /// Inserts only if no entry with the same id exists yet (used by cloud download/merge).
    func appendUnique(_ entry: QuickLogEntry) {
        var current = load()
        guard !current.contains(where: { $0.id == entry.id }) else { return }
        current.insert(entry, at: 0)
        persist(current)
    }

    func removeLast(kind: BlobKind) {
        var current = load()
        if let idx = current.firstIndex(where: { $0.kind == kind }) {
            current.remove(at: idx)
            persist(current)
        }
    }

    private func persist(_ entries: [QuickLogEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.set(Date(), forKey: dateKey)
        }
    }
}
