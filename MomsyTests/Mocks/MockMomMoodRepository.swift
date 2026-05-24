@testable import Momsy
import Foundation

final class MockMomMoodRepository: MomMoodRepository {
    var entries: [MomMoodEntry] = []
    var shouldThrow = false

    func getEntries(from: Date, to: Date) async throws -> [MomMoodEntry] {
        if shouldThrow { throw TestError.mock }
        return entries.filter { $0.date >= from && $0.date <= to }
                      .sorted { $0.date > $1.date }
    }

    func add(_ entry: MomMoodEntry) async throws {
        if shouldThrow { throw TestError.mock }
        entries.append(entry)
    }

    func latestEntry() async throws -> MomMoodEntry? {
        if shouldThrow { throw TestError.mock }
        return entries.max(by: { $0.date < $1.date })
    }
}
