import Foundation

protocol FeedingRepository {
    func getEntries(for date: Date) async throws -> [FeedingEntry]
    func getEntries(from: Date, to: Date) async throws -> [FeedingEntry]
    func add(_ entry: FeedingEntry) async throws
    func delete(id: UUID) async throws
}
