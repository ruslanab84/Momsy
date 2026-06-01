import Foundation

protocol WalkRepository {
    func start() async throws -> WalkEntry
    func stop(_ entry: WalkEntry) async throws -> WalkEntry
    func getEntries(from: Date, to: Date) async throws -> [WalkEntry]
    func add(_ entry: WalkEntry) async throws
    func upsert(_ entries: [WalkEntry]) async throws
}
