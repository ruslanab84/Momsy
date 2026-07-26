import Testing
import Foundation
@testable import Momsy

@Suite("InviteCodeFormat")
struct InviteCodeFormatTests {

    @Test("generated code matches the canonical MOMSY-XXXX-XXXX-XXXX shape")
    func generatedShape() {
        let code = InviteCodeFormat.generate()
        #expect(code.count == 20)
        #expect(code.hasPrefix("MOMSY-"))
        #expect(code.split(separator: "-").count == 4)
        #expect(InviteCodeFormat.isValid(code))
    }

    @Test("generated codes only use the ambiguity-free alphabet")
    func generatedAlphabet() {
        let allowed = Set("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        for _ in 0..<200 {
            let body = InviteCodeFormat.generate()
                .dropFirst("MOMSY-".count)
                .filter { $0 != "-" }
            #expect(body.allSatisfy { allowed.contains($0) })
        }
    }

    @Test("2000 generated codes are all distinct")
    func generatorEntropy() {
        let codes = Set((0..<2000).map { _ in InviteCodeFormat.generate() })
        #expect(codes.count == 2000)
    }

    @Test("legacy six-character codes are rejected")
    func rejectsLegacyCodes() {
        #expect(!InviteCodeFormat.isValid("MOMSY-ABC234"))
        #expect(!InviteCodeFormat.isValid("MOMSY-BBB234"))
        #expect(!InviteCodeFormat.isValid("MOMSY-JOIN01"))
    }

    @Test("malformed codes are rejected")
    func rejectsMalformed() {
        #expect(!InviteCodeFormat.isValid(""))
        #expect(!InviteCodeFormat.isValid("MOMSY"))
        #expect(!InviteCodeFormat.isValid("momsy-a2b3-c4d5-e6f7"))       // lowercase
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5"))            // 2 группы
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F7-G8H9"))  // 4 группы
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6FI"))       // I вне алфавита
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F0"))       // 0 вне алфавита
        #expect(!InviteCodeFormat.isValid("XXXXX-A2B3-C4D5-E6F7"))       // чужой префикс
        #expect(!InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F7\n"))     // хвостовой перевод строки
    }

    @Test("a hand-written canonical code is accepted")
    func acceptsCanonical() {
        #expect(InviteCodeFormat.isValid("MOMSY-A2B3-C4D5-E6F7"))
    }

    @Test("the Swift pattern and the Firestore rules pattern are identical")
    func patternIsShared() {
        #expect(InviteCodeFormat.pattern == "^MOMSY(-[A-HJ-NP-Z2-9]{4}){3}$")
    }
}
