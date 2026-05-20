import Foundation

final class LocalLeapsRepository: LeapsRepository {
    private let key = "local_leaps_progress"

    private func load() throws -> [LeapProgress] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([LeapProgress].self, from: data)
    }

    private func save(_ items: [LeapProgress]) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(items), forKey: key)
    }

    func getAllProgress() async throws -> [LeapProgress] {
        try load()
    }

    func saveProgress(_ progress: LeapProgress) async throws {
        var items = try load()
        if let idx = items.firstIndex(where: { $0.id == progress.id }) {
            items[idx] = progress
        } else {
            items.append(progress)
        }
        try save(items)
    }

    func resetProgress(id: Int) async throws {
        var items = try load()
        items.removeAll { $0.id == id }
        try save(items)
    }
}
