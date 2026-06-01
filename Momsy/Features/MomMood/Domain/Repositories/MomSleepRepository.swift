import Foundation

protocol MomSleepRepository {
    func getEntries(from: Date, to: Date) async throws -> [SleepEntry]
    func add(_ entry: SleepEntry) async throws
    func update(_ entry: SleepEntry) async throws
    func upsert(_ entries: [SleepEntry]) async throws
    func delete(id: UUID) async throws
}
