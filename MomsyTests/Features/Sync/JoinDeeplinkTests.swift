import Testing
import Foundation
@testable import Momsy

@Suite("JoinDeeplink")
struct JoinDeeplinkTests {

    @Test func parsesValidJoinURL() {
        let url = URL(string: "momsy://join?code=momsy-abc123")!
        #expect(JoinDeeplink.code(from: url) == "MOMSY-ABC123")
    }

    @Test func nilForWrongHost() {
        #expect(JoinDeeplink.code(from: URL(string: "momsy://feeding?code=x")!) == nil)
    }

    @Test func nilWhenCodeMissing() {
        #expect(JoinDeeplink.code(from: URL(string: "momsy://join")!) == nil)
    }

    @Test func nilForWrongScheme() {
        #expect(JoinDeeplink.code(from: URL(string: "https://join?code=x")!) == nil)
    }
}
