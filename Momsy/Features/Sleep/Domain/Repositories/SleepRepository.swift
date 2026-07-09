import Foundation

protocol SleepRepository {
    func getEntries(from: Date, to: Date) async throws -> [SleepEntry]
    func add(_ entry: SleepEntry) async throws
    /// Inserts only entries whose id is not already stored (used by cloud download/merge).
    func upsert(_ entries: [SleepEntry]) async throws
    func update(_ entry: SleepEntry) async throws
    func delete(id: UUID) async throws
}

extension SleepRepository {
    /// Removes entries tombstoned by another device during cloud merge.
    func applyDeletions(_ ids: Set<UUID>) async throws {
        for id in ids { try await delete(id: id) }
    }

    func getEntries(
        overlapping dayStart: Date,
        until dayEnd: Date,
        lookback: TimeInterval = 24 * 3600
    ) async throws -> [SleepEntry] {
        let widened = try await getEntries(from: dayStart.addingTimeInterval(-lookback), to: dayEnd)
        return widened.filter {
            SleepDayWindow.overlaps(
                start: $0.startDate,
                end: $0.endDate,
                dayStart: dayStart,
                dayEnd: dayEnd
            )
        }
    }
}
