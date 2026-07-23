import Testing
import FirebaseFirestore
@testable import Momsy

struct FamilyMembershipCheckTests {
    @Test func permissionDeniedClassifiesAsRevoked() {
        let error = NSError(domain: FirestoreErrorCode.errorDomain,
                            code: FirestoreErrorCode.permissionDenied.rawValue)
        #expect(FamilyManager.classifyMembershipError(error) == .revoked)
    }

    @Test func transientErrorsClassifyAsUnknown() {
        let offline = NSError(domain: FirestoreErrorCode.errorDomain,
                              code: FirestoreErrorCode.unavailable.rawValue)
        let foreign = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        #expect(FamilyManager.classifyMembershipError(offline) == .unknown)
        #expect(FamilyManager.classifyMembershipError(foreign) == .unknown)
    }

    @Test func onlyConfirmedRevocationMakesCurrentFamilyDataOptional() {
        let permissionDenied = NSError(
            domain: FirestoreErrorCode.errorDomain,
            code: FirestoreErrorCode.permissionDenied.rawValue
        )
        let unavailable = NSError(
            domain: FirestoreErrorCode.errorDomain,
            code: FirestoreErrorCode.unavailable.rawValue
        )

        #expect(FamilyManager.canTreatCurrentFamilyAsEmpty(
            dataReadError: permissionDenied,
            confirmedMembership: .revoked
        ))
        #expect(!FamilyManager.canTreatCurrentFamilyAsEmpty(
            dataReadError: permissionDenied,
            confirmedMembership: .member
        ))
        #expect(!FamilyManager.canTreatCurrentFamilyAsEmpty(
            dataReadError: permissionDenied,
            confirmedMembership: .unknown
        ))
        #expect(!FamilyManager.canTreatCurrentFamilyAsEmpty(
            dataReadError: unavailable,
            confirmedMembership: .revoked
        ))
    }

    @Test func revokedConfirmedOnlyByHealthySelfRead() {
        #expect(FamilyManager.gatedMembershipCheck(raw: .revoked, selfReadSucceeded: true) == .revoked)
        #expect(FamilyManager.gatedMembershipCheck(raw: .revoked, selfReadSucceeded: false) == .unknown)
    }

    @Test func nonRevokedResultsBypassTheGate() {
        #expect(FamilyManager.gatedMembershipCheck(raw: .member, selfReadSucceeded: false) == .member)
        #expect(FamilyManager.gatedMembershipCheck(raw: .unknown, selfReadSucceeded: false) == .unknown)
    }
}
