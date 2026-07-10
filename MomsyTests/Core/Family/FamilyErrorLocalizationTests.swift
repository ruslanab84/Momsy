import Testing
@testable import Momsy

@Suite("FamilyError localization")
struct FamilyErrorLocalizationTests {
    @Test("invalidOrExpiredCode renders the localized join-failed message")
    func invalidCodeMessageIsLocalized() {
        #expect(
            FamilyError.invalidOrExpiredCode.errorDescription
            == LocalizationManager.shared.strings.joinFailedMessage
        )
    }
}
