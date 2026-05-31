import Foundation
@testable import Momsy

final class MockStoolRepository: StoolRepository, @unchecked Sendable {
    var entries: [Date] = []
    var addedDates: [Date] = []

    var addedEntries: [StoolEntry] = []

    func add(date: Date) async throws {
        addedDates.append(date)
        entries.append(date)
    }

    func add(id: UUID, date: Date) async throws {
        addedEntries.append(StoolEntry(id: id, date: date))
        addedDates.append(date)
        entries.append(date)
    }

    func upsert(_ newEntries: [StoolEntry]) async throws {
        let existing = Set(addedEntries.map(\.id))
        for entry in newEntries where !existing.contains(entry.id) {
            addedEntries.append(entry)
            entries.append(entry.date)
        }
    }

    func getEntries(from: Date, to: Date) async throws -> [Date] {
        entries.filter { $0 >= from && $0 <= to }
    }
}
