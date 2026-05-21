import Foundation

struct QuickLogEntry: Codable {
    let id: UUID
    let time: Date
    let kind: BlobKind
    let label: String
}

final class QuickLogRepository {
    private let key     = "quick_log_today_entries"
    private let dateKey = "quick_log_today_date"

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
