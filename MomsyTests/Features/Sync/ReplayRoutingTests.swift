import Testing
import Foundation
@testable import Momsy

/// Routing rules for replaying writes that were queued before the family path was ready.
/// Guards against the two ways a replayed log could be misattributed: into a child it
/// doesn't belong to, or into a family the user has since left.
@Suite("ReplayRouting")
struct ReplayRoutingTests {

    @Test func routesToStampedBabyNotTheActiveOne() {
        // Queued for baby B1 while B2 is now active → must target B1.
        #expect(BabySyncService.replayTargetBabyId(
            entryFamilyId: "F", entryBabyId: "B1",
            currentFamilyId: "F", currentBabyId: "B2") == "B1")
    }

    @Test func skipsWriteStampedWithADifferentFamily() {
        // Leftover from a family the user left → never replay into the joined family.
        #expect(BabySyncService.replayTargetBabyId(
            entryFamilyId: "F-old", entryBabyId: "B1",
            currentFamilyId: "F-new", currentBabyId: "B2") == nil)
    }

    @Test func unknownBabyAtEnqueueFallsBackToCurrentBaby() {
        // Pre-baby onboarding write (babyId unknown) → current baby is the only target.
        #expect(BabySyncService.replayTargetBabyId(
            entryFamilyId: "", entryBabyId: "",
            currentFamilyId: "F", currentBabyId: "B2") == "B2")
    }

    @Test func skipsWhenNoCurrentFamily() {
        #expect(BabySyncService.replayTargetBabyId(
            entryFamilyId: "", entryBabyId: "B1",
            currentFamilyId: "", currentBabyId: "B2") == nil)
    }

    @Test func skipsWhenTargetIsUnresolvable() {
        // No stamped baby and no current baby → nothing safe to target.
        #expect(BabySyncService.replayTargetBabyId(
            entryFamilyId: "F", entryBabyId: "",
            currentFamilyId: "F", currentBabyId: "") == nil)
    }
}
