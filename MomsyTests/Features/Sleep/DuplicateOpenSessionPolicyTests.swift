import Testing
import Foundation
@testable import Momsy

@Suite
struct DuplicateOpenSessionPolicyTests {

    private let baseDate = Date(timeIntervalSinceReferenceDate: 1_000_000)

    private func entry(id: UUID = UUID(), startOffset: TimeInterval, startedBy: String? = nil) -> SleepEntry {
        SleepEntry(id: id, startDate: baseDate.addingTimeInterval(startOffset), endDate: nil,
                  startedBy: startedBy)
    }

    // MARK: - canonical

    @Test
    func canonicalPicksEarliestStart() {
        let earlier = entry(startOffset: 0)
        let later = entry(startOffset: 60)
        let result = DuplicateOpenSessionPolicy.canonical([later, earlier])
        #expect(result?.id == earlier.id)
    }

    @Test
    func canonicalTieBreaksByIdOnEqualStartDate() {
        let idA = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let idB = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let a = entry(id: idA, startOffset: 0)
        let b = entry(id: idB, startOffset: 0)
        let result = DuplicateOpenSessionPolicy.canonical([b, a])
        #expect(result?.id == idA)
    }

    // MARK: - ownDiscards

    @Test
    func ownDiscardsExcludesCanonical() {
        let canonical = entry(startOffset: 0, startedBy: "uid-a")
        let discards = DuplicateOpenSessionPolicy.ownDiscards(
            [canonical], canonical: canonical, currentUid: "uid-a", window: 180
        )
        #expect(discards.isEmpty)
    }

    @Test
    func ownDiscardsExcludesRemoteOwnedEntries() {
        let canonical = entry(startOffset: 0, startedBy: "uid-a")
        let remoteDuplicate = entry(startOffset: 30, startedBy: "uid-b")
        let discards = DuplicateOpenSessionPolicy.ownDiscards(
            [canonical, remoteDuplicate], canonical: canonical, currentUid: "uid-a", window: 180
        )
        #expect(discards.isEmpty)
    }

    @Test
    func ownDiscardsExcludesOwnEntriesBeyondWindow() {
        let canonical = entry(startOffset: 0, startedBy: "uid-a")
        let farOwnDuplicate = entry(startOffset: 300, startedBy: "uid-a")
        let discards = DuplicateOpenSessionPolicy.ownDiscards(
            [canonical, farOwnDuplicate], canonical: canonical, currentUid: "uid-a", window: 180
        )
        #expect(discards.isEmpty)
    }

    @Test
    func ownDiscardsIncludesOwnNearDuplicates() {
        let canonical = entry(startOffset: 0, startedBy: "uid-a")
        let nearOwnDuplicate = entry(startOffset: 30, startedBy: "uid-a")
        let discards = DuplicateOpenSessionPolicy.ownDiscards(
            [canonical, nearOwnDuplicate], canonical: canonical, currentUid: "uid-a", window: 180
        )
        #expect(discards.map(\.id) == [nearOwnDuplicate.id])
    }
}
