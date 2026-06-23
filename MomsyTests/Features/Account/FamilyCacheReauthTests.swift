import Testing
@testable import Momsy

/// Regression coverage for the family-cache corruption on account re-auth:
/// when `AuthManager.linkOrSignIn` falls back to `signIn` (credential already in
/// use), Firebase issues a NEW uid, but `FamilyManager` had been caching the
/// anonymous session's `familyId` and early-returning from `setup`, leaving the
/// user bound to an empty anonymous family. The cache must be treated as valid
/// only for the uid that owns it.
@Suite("FamilyManager cache staleness on uid change")
struct FamilyCacheReauthTests {

    @Test("fresh install / legacy cache (no owner uid) is not stale")
    func noOwnerUidIsNotStale() {
        #expect(FamilyManager.cacheIsStale(cachedOwnerUid: nil, currentUid: "anon-1") == false)
    }

    @Test("relaunch or successful link keeps same uid → cache stays valid")
    func sameUidIsNotStale() {
        #expect(FamilyManager.cacheIsStale(cachedOwnerUid: "anon-1", currentUid: "anon-1") == false)
    }

    @Test("anonymous → existing-account sign-in changes uid → cache is stale")
    func changedUidIsStale() {
        #expect(FamilyManager.cacheIsStale(cachedOwnerUid: "anon-1", currentUid: "real-1") == true)
    }
}
