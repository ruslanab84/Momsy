import Testing
import FirebaseFirestore
@testable import Momsy

struct BabySyncErrorClassificationTests {
    @Test func permissionDeniedIsPermanent() {
        let denied = NSError(domain: FirestoreErrorCode.errorDomain,
                             code: FirestoreErrorCode.permissionDenied.rawValue)
        #expect(BabySyncService.isPermissionDenied(denied))
    }

    @Test func transientErrorsAreRetryable() {
        let offline = NSError(domain: FirestoreErrorCode.errorDomain,
                              code: FirestoreErrorCode.unavailable.rawValue)
        let deadline = NSError(domain: FirestoreErrorCode.errorDomain,
                               code: FirestoreErrorCode.deadlineExceeded.rawValue)
        let foreign = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        #expect(!BabySyncService.isPermissionDenied(offline))
        #expect(!BabySyncService.isPermissionDenied(deadline))
        #expect(!BabySyncService.isPermissionDenied(foreign))
    }
}
