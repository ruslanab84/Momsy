@testable import Momsy
import Foundation

final class MockDiaryRepository: DiaryRepository {
    var items: [StoredDiaryItem] = []
    var shouldThrow = false
    var throwOnAdd = false
    var addedItems: [StoredDiaryItem] = []

    func getEntries(from: Date, to: Date) async throws -> [StoredDiaryItem] {
        if shouldThrow { throw TestError.mock }
        return items.filter { $0.date >= from && $0.date <= to }
    }

    func add(_ item: StoredDiaryItem) async throws {
        if throwOnAdd { throw TestError.mock }
        addedItems.append(item)
        items.append(item)
    }

    func upsert(_ newItems: [StoredDiaryItem]) async throws {
        if shouldThrow { throw TestError.mock }
        let existing = Set(items.map(\.id))
        for item in newItems where !existing.contains(item.id) {
            addedItems.append(item)
            items.append(item)
        }
    }

    func update(_ item: StoredDiaryItem) async throws {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
        }
    }

    func delete(id: UUID) async throws {
        items.removeAll { $0.id == id }
    }
}
