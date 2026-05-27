import Foundation

protocol BathRepository {
    func start() async throws -> BathEntry
    func stop(_ entry: BathEntry) async throws -> BathEntry
    func getEntries(from: Date, to: Date) async throws -> [BathEntry]
    func add(_ entry: BathEntry) async throws
}
