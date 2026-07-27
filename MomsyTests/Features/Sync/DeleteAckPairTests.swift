import Testing
import Foundation
import FirebaseFirestore
@testable import Momsy

@Suite("DeleteAckPair")
struct DeleteAckPairTests {

    private func denied() -> NSError {
        NSError(domain: FirestoreErrorCode.errorDomain,
                code: FirestoreErrorCode.permissionDenied.rawValue,
                userInfo: nil)
    }

    private func offline() -> NSError {
        NSError(domain: FirestoreErrorCode.errorDomain,
                code: FirestoreErrorCode.unavailable.rawValue,
                userInfo: nil)
    }

    @Test("no outcome is reported until both writes have landed")
    func waitsForBothAcks() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }

        pair.report(nil)
        #expect(outcomes.isEmpty)

        pair.report(nil)
        #expect(outcomes == [.acknowledged])
    }

    @Test("a rules denial on either write is permanent")
    func deniedIsPermanent() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(nil)
        pair.report(denied())
        #expect(outcomes == [.permanentlyDenied])
    }

    @Test("an offline failure stays retryable")
    func offlineIsTransient() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(offline())
        pair.report(nil)
        #expect(outcomes == [.transientFailure])
    }

    @Test("the first recorded failure decides the outcome")
    func firstFailureWins() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(denied())
        pair.report(offline())
        #expect(outcomes == [.permanentlyDenied])
    }

    @Test("the outcome is reported exactly once")
    func reportsOnce() {
        var outcomes: [DeleteAckPair.Outcome] = []
        let pair = DeleteAckPair { outcomes.append($0) }
        pair.report(nil)
        pair.report(nil)
        pair.report(nil)
        #expect(outcomes.count == 1)
    }
}
