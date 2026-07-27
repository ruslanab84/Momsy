import Testing
import Foundation
@testable import Momsy

@Suite("LocalInviteService")
struct LocalInviteServiceTests {

    @Test("the local fallback issues codes in the canonical format")
    func generatesCanonicalCode() {
        let service = LocalInviteService()
        let code = service.regenerate()
        #expect(InviteCodeFormat.isValid(code))
    }

    @Test("a cached code is reused while it is still valid")
    func reusesCachedCode() {
        let service = LocalInviteService()
        let first = service.regenerate()
        #expect(service.currentCode() == first)
    }

    @Test("the invite URL round-trips through the deeplink parser")
    func urlRoundTrips() {
        let service = LocalInviteService()
        let code = service.regenerate()
        let url = service.inviteURL(for: code)
        #expect(JoinDeeplink.normalize(rawCode: url) == code)
    }
}
