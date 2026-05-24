import Foundation

protocol DiaperRepository {
    func getEntries(from: Date, to: Date) async throws -> [DiaperEntry]
    func add(_ entry: DiaperEntry) async throws
    func removeLatest(on day: Date) async throws
    func countToday() async throws -> Int
}
