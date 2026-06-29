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

    @Test func nilWhenCodeContainsSlash() {
        #expect(JoinDeeplink.code(from: URL(string: "momsy://join?code=momsy/abc")!) == nil)
        #expect(JoinDeeplink.code(from: URL(string: "momsy://join?code=momsy%2Fabc")!) == nil)
    }

    @Test func nilWhenCodeIsFirestoreReservedId() {
        #expect(JoinDeeplink.code(from: URL(string: "momsy://join?code=.")!) == nil)
        #expect(JoinDeeplink.code(from: URL(string: "momsy://join?code=..")!) == nil)
        #expect(JoinDeeplink.code(from: URL(string: "momsy://join?code=__reserved__")!) == nil)
    }

    // MARK: - normalize(rawCode:) — user-entered text (bare code OR pasted link)

    @Test func normalizesBareCode() {
        #expect(JoinDeeplink.normalize(rawCode: "momsy-abc123") == "MOMSY-ABC123")
    }

    @Test func normalizesPastedFullDeeplink() {
        // The crash scenario: user pastes the whole invite link into the code field.
        #expect(JoinDeeplink.normalize(rawCode: "momsy://join?code=MOMSY-H2HDS7") == "MOMSY-H2HDS7")
    }

    @Test func normalizeTrimsSurroundingWhitespace() {
        #expect(JoinDeeplink.normalize(rawCode: "  MOMSY-ABC  ") == "MOMSY-ABC")
    }

    @Test func normalizeReturnsNilForEmptyInput() {
        #expect(JoinDeeplink.normalize(rawCode: "") == nil)
        #expect(JoinDeeplink.normalize(rawCode: "   ") == nil)
    }

    @Test func normalizeRejectsNonDeeplinkURL() {
        // A non-momsy URL must not fall through to an illegal Firestore doc path with "//".
        #expect(JoinDeeplink.normalize(rawCode: "https://momsy.app/join?code=abc") == nil)
    }

    @Test func normalizeRejectsSlashInCode() {
        #expect(JoinDeeplink.normalize(rawCode: "momsy/abc") == nil)
        #expect(JoinDeeplink.normalize(rawCode: "momsy://join?code=momsy%2Fabc") == nil)
    }

    @Test func normalizeRejectsFirestoreReservedIds() {
        #expect(JoinDeeplink.normalize(rawCode: ".") == nil)
        #expect(JoinDeeplink.normalize(rawCode: "..") == nil)
        #expect(JoinDeeplink.normalize(rawCode: "__reserved__") == nil)
    }
}
