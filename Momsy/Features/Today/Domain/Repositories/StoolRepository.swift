import Foundation

struct StoolEntry: Identifiable {
    let id: UUID
    let date: Date
}

protocol StoolRepository {
    func add(date: Date) async throws
    func add(id: UUID, date: Date) async throws
    /// Inserts only entries whose id is not already stored (used by cloud download/merge).
    func upsert(_ entries: [StoolEntry]) async throws
    func getEntries(from: Date, to: Date) async throws -> [Date]
}
