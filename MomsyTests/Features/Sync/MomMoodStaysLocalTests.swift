import Testing
import Foundation
@testable import Momsy

/// `Momsy/PrivacyInfo.xcprivacy` deliberately omits `NSPrivacyCollectedDataTypeSensitiveInfo`
/// because parent mood / EPDS records never leave the device. If mood ever gains a Firestore
/// subcollection, this fails — the privacy manifest and the App Store labels must be updated
/// in the same change.
@Suite("MomMood stays local")
struct MomMoodStaysLocalTests {

    @Test func noMoodSubcollectionIsEverSynced() {
        let offenders = BabySyncService.allSubcollections.filter {
            let name = $0.lowercased()
            return name.contains("mood") || name.contains("epds") || name.contains("wellbeing")
        }

        #expect(offenders.isEmpty,
                "momMood reached Firestore via \(offenders) — update PrivacyInfo.xcprivacy and App Store privacy labels")
    }
}
