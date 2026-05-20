import Foundation

final class LocalDiaryRepository: DiaryRepository {
    private let key = "local_diary_entries"

    private func load() throws -> [StoredDiaryItem] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([StoredDiaryItem].self, from: data)
    }

    private func save(_ items: [StoredDiaryItem]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(items), forKey: key)
    }

    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem] {
        try load().filter { $0.date >= from && $0.date <= to }
    }

    func add(_ item: StoredDiaryItem) async throws {
        var items = try load()
        items.append(item)
        try save(items)
    }

    func update(_ item: StoredDiaryItem) async throws {
        var items = try load()
        if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx] = item }
        try save(items)
    }

    func delete(id: UUID) async throws {
        var items = try load()
        items.removeAll { $0.id == id }
        try save(items)
    }
}
