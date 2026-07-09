import Testing
import Foundation
@testable import Momsy

@Suite
struct SleepSessionOwnershipTests {

    // MARK: - isRemoteOwned

    @Test
    func nilOwnerIsNotRemoteOwned() {
        #expect(!SleepSessionOwnership.isRemoteOwned(startedBy: nil, currentUid: "uid-a"))
    }

    @Test
    func emptyOwnerIsNotRemoteOwned() {
        #expect(!SleepSessionOwnership.isRemoteOwned(startedBy: "", currentUid: "uid-a"))
    }

    @Test
    func ownerMatchingCurrentUidIsNotRemoteOwned() {
        #expect(!SleepSessionOwnership.isRemoteOwned(startedBy: "uid-a", currentUid: "uid-a"))
    }

    @Test
    func ownerDifferentFromCurrentUidIsRemoteOwned() {
        #expect(SleepSessionOwnership.isRemoteOwned(startedBy: "uid-a", currentUid: "uid-b"))
    }

    @Test
    func ownerSetWithNilCurrentUidIsRemoteOwned() {
        #expect(SleepSessionOwnership.isRemoteOwned(startedBy: "uid-a", currentUid: nil))
    }

    // MARK: - shouldMirrorRemoteOpen

    @Test
    func justUnderMaxDurationShouldMirror() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let now = start.addingTimeInterval(23 * 3600 + 59 * 60)
        #expect(SleepSessionOwnership.shouldMirrorRemoteOpen(start: start, now: now, maxDuration: 24 * 3600))
    }

    @Test
    func justOverMaxDurationShouldNotMirror() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let now = start.addingTimeInterval(24 * 3600 + 1)
        #expect(!SleepSessionOwnership.shouldMirrorRemoteOpen(start: start, now: now, maxDuration: 24 * 3600))
    }
}
