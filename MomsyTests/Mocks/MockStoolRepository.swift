import Foundation
@testable import Momsy

final class MockStoolRepository: StoolRepository, @unchecked Sendable {
    var entries: [Date] = []
    var addedDates: [Date] = []

    func add(date: Date) async throws {
        addedDates.append(date)
        entries.append(date)
    }

    func getEntries(from: Date, to: Date) async throws -> [Date] {
        entries.filter { $0 >= from && $0 <= to }
    }
}
