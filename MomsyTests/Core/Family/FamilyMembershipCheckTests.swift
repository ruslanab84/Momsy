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
}
