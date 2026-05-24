import Foundation

protocol MomMoodRepository {
    func getEntries(from: Date, to: Date) async throws -> [MomMoodEntry]
    func add(_ entry: MomMoodEntry) async throws
    func latestEntry() async throws -> MomMoodEntry?
}
