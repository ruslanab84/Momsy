import Foundation

protocol StoolRepository {
    func add(date: Date) async throws
    func getEntries(from: Date, to: Date) async throws -> [Date]
}
