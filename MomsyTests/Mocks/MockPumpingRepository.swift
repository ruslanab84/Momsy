@testable import Momsy
import Foundation

final class MockPumpingRepository: PumpingRepository {
    var entries: [PumpingEntry] = []

    func start(side: PumpingSide) async throws -> PumpingEntry {
        PumpingEntry(id: UUID(), date: Date(), durationSeconds: 0, side: side, volumeML: 0)
    }
    func stop(_ entry: PumpingEntry, volumeML: Int) async throws -> PumpingEntry { entry }
    func getEntries(from: Date, to: Date) async throws -> [PumpingEntry] {
        entries.filter { $0.date >= from && $0.date < to }
    }
    func logManual(date: Date, durationMinutes: Int, side: PumpingSide, volumeML: Int) async throws -> PumpingEntry {
        let entry = PumpingEntry(id: UUID(), date: date, durationSeconds: durationMinutes * 60,
                                 side: side, volumeML: volumeML)
        entries.append(entry)
        return entry
    }
    func upsert(_ newEntries: [PumpingEntry]) async throws {
        let existing = Set(entries.map(\.id))
        entries.append(contentsOf: newEntries.filter { !existing.contains($0.id) })
    }
}
