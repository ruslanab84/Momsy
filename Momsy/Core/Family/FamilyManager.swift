import Foundation
import Combine
import os
import FirebaseFirestore
import FirebaseAuth

// UserDefaults keys shared across module so repos can read without actor hopping
let kFamilyIdDefaultsKey = "familyId_v1"
let kBabyIdDefaultsKey = "babyId_v1"
// The uid that owns the cached familyId. A cached familyId is valid only for this
// uid; a different uid means the cache is stale and must be re-read from Firestore.
let kFamilyOwnerUidDefaultsKey = "familyOwnerUid_v1"

extension Notification.Name {
    /// Posted after the caller joins an existing family, so the app re-pulls that
    /// family's data (the joined family's logs aren't local yet).
    static let familyDidJoin = Notification.Name("familyDidJoin")
    /// Posted after this device detects it was removed from its family (rules deny
    /// the caller's own member-doc read). UI shows the "removed from family" alert.
    static let familyMembershipRevoked = Notification.Name("familyMembershipRevoked")
}

enum FamilyError: LocalizedError {
    case noFamilyId
    case invalidOrExpiredCode
    case wouldAbandonExistingFamily

    var errorDescription: String? {
        switch self {
        case .noFamilyId:                 return "Family not set up. Please sign in."
        case .invalidOrExpiredCode:       return LocalizationManager.shared.strings.joinFailedMessage
        case .wouldAbandonExistingFamily: return "You already belong to a family."
        }
    }
}

@MainActor
final class FamilyManager: ObservableObject {
    static let shared = FamilyManager()
    /// `userInfo` key on `.familyDidJoin` carrying the family id the user left,
    /// so observers can tell a real switch from a first-ever join.
    nonisolated static let previousFamilyIdUserInfoKey = "previousFamilyId"

    @Published private(set) var familyId: String?
    @Published private(set) var isReady = false

    /// True while an explicit invite-join flow owns family state. `setup()` bails while
    /// set so the auth state listener — fired by the join's own sign-in — cannot race
    /// it into creating a parallel fresh family. In-memory only: the race exists only
    /// within one process lifetime.
    private(set) var joinInFlight = false

    /// Assigned by `AppContainer` at startup. Runs BEFORE the revoked family is
    /// detached and replaced, so the old family's local children are purged before
    /// any new-family sync could re-upload them (same invariant as the join-switch
    /// purge in `observeFamilyJoin`).
    var onMembershipRevoked: ((_ revokedFamilyId: String) async -> Void)?

    /// One server-truth membership read per process launch on the cached-familyId
    /// path; revocation while the app keeps running is caught on the next launch.
    private var hasVerifiedMembershipThisLaunch = false

    enum MembershipCheck { case member, revoked, unknown }

    private var db: Firestore { Firestore.firestore() }
    private var isSettingUp = false
    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "Family")

    private init() {
        familyId = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey)
        isReady = familyId != nil
    }

    /// True when a cached familyId belongs to a different uid than the one now
    /// signing in. This happens when `AuthManager.linkOrSignIn` falls back to a
    /// plain `signIn` (the credential already belongs to an existing account):
    /// Firebase issues a new uid, but the anonymous session's familyId is still
    /// cached. Without invalidation, `setup` early-returns on that stale id and
    /// strands the user in an empty anonymous family. A nil cached uid (fresh
    /// install, or a cache written before this key existed) is treated as valid.
    nonisolated static func cacheIsStale(cachedOwnerUid: String?, currentUid: String) -> Bool {
        guard let cachedOwnerUid else { return false }
        return cachedOwnerUid != currentUid
    }

    func beginJoinFlow() { joinInFlight = true }
    func endJoinFlow() { joinInFlight = false }

    func resetStaleCacheIfNeeded(for uid: String) {
        if Self.cacheIsStale(
            cachedOwnerUid: UserDefaults.standard.string(forKey: kFamilyOwnerUidDefaultsKey),
            currentUid: uid
        ) {
            reset()
        }
    }

    /// Called by AuthManager's state listener on every sign-in / app launch with existing session.
    /// Reads the user's familyId from Firestore; creates a new family if none exists.
    func setup(uid: String, displayName: String) async throws {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        guard !joinInFlight else {
            Self.log.info("Deferring family setup — invite join in flight")
            return
        }

        let suppressedRestoreStore = UserDefaultsSuppressedFamilyRestoreStore()
        let restoreSuppressed = suppressedRestoreStore.isRestoreSuppressed(for: uid)
        if restoreSuppressed {
            reset()
        }

        // A uid change since the cache was written (e.g. signing into an existing
        // account that replaced the anonymous user) invalidates the cached familyId.
        resetStaleCacheIfNeeded(for: uid)

        // Cached familyId: verify roster membership against the server ONCE per
        // launch. A member removed by a family admin otherwise keeps a dead cache
        // forever — every read/write silently rules-denied. On revocation, fall
        // through below and start a fresh personal family.
        if let cachedId = familyId {
            if hasVerifiedMembershipThisLaunch { isReady = true; return }
            // Set BEFORE the await: setup() is re-entered concurrently (launch +
            // auth listener) and the suspension below would otherwise let both
            // callers run the check — double read, double detach, double alert.
            hasVerifiedMembershipThisLaunch = true
            let check = await confirmMembershipHealthGated(familyId: cachedId, uid: uid)
            switch check {
            case .member, .unknown:
                isReady = true
                return
            case .revoked:
                await detachFromRevokedFamily(uid: uid, familyId: cachedId)
                // Continue below: users/{uid}.familyId is cleared, a new family is created.
            }
        }

        // Prevent concurrent invocations (e.g. state listener fires on launch + sign-in)
        guard !isSettingUp else { return }
        isSettingUp = true
        defer { isSettingUp = false }

        let userRef = db.collection("users").document(uid)
        // This routing document decides whether a provider login adopts an existing
        // family or starts fresh. Read it from the backend, not Firestore's persistent
        // cache, so a just-deleted account cannot reattach to a stale cached familyId.
        let userDoc = try await userRef.getDocument(source: .server)
        var existingId = userDoc.data()?["familyId"] as? String

        // Membership must be confirmed BEFORE persisting: a stale routing field
        // pointing at a family the caller was removed from must not be adopted.
        if let candidate = existingId, !restoreSuppressed {
            if await confirmMembership(familyId: candidate, uid: uid) == .revoked {
                await detachFromRevokedFamily(uid: uid, familyId: candidate)
                existingId = nil
            }
        }

        if let existingId, !restoreSuppressed {
            persist(familyId: existingId, ownerUid: uid)
            try await ensureMemberDocument(
                familyId: existingId,
                uid: uid,
                displayName: displayName,
                defaultRoleRaw: FamilyRole.mom.rawValue
            )
        } else {
            if let existingId, restoreSuppressed {
                let memberRef = db.collection("families").document(existingId)
                    .collection("members").document(uid)
                // permissionDenied ⇒ doc отсутствует (rules требуют его существования
                // для read). Прочие ошибки (сеть, App Check) пробрасываются наверх:
                // transient-сбой не должен приводить к созданию новой семьи.
                let memberSnap: DocumentSnapshot?
                do {
                    memberSnap = try await memberRef.getDocument(source: .server)
                } catch let error where Self.classifyMembershipError(error) == .revoked {
                    memberSnap = nil
                }
                let resolution = Self.resolveSuppressedRestore(
                    memberDocExists: memberSnap?.exists == true,
                    memberHasInviteCode: (memberSnap?.data()?["inviteCode"] as? String) != nil
                )
                switch resolution {
                case .adoptInviteMembership:
                    // Членство создано инвайт-join'ом ПОСЛЕ намерения удаления —
                    // легитимно. Снимаем suppression и адоптируем как обычный вход.
                    suppressedRestoreStore.clearSuppression(for: uid)
                    persist(familyId: existingId, ownerUid: uid)
                    try await ensureMemberDocument(
                        familyId: existingId,
                        uid: uid,
                        displayName: displayName,
                        defaultRoleRaw: FamilyRole.mom.rawValue
                    )
                    isReady = true
                    return
                case .discardStaleMembership:
                    try? await memberRef.delete()
                case .startFresh:
                    break
                }
            }
            let newId = try await createFamily(for: uid)
            try await ensureMemberDocument(
                familyId: newId,
                uid: uid,
                displayName: displayName,
                defaultRoleRaw: FamilyRole.mom.rawValue,
                bootstrapCreator: true
            )
            try await db.collection("families").document(newId)
                .updateData(["bootstrapComplete": true])
            try await userRef.setData(
                ["familyId": newId, "displayName": displayName],
                merge: true
            )
            persist(familyId: newId, ownerUid: uid)
            try await BabySyncService().setupBabyProfile(uid: uid, displayName: displayName)
            suppressedRestoreStore.clearSuppression(for: uid)
            Self.log.info("Created new family \(newId, privacy: .public) for user")
        }
        isReady = true
    }

    @discardableResult
    func createFamily(for uid: String) async throws -> String {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        let ref = db.collection("families").document()
        try await ref.setData([
            "createdAt": Timestamp(date: Date()),
            "createdBy": uid,
            "bootstrapComplete": false
        ])
        return ref.documentID
    }

    /// Whether the caller's current family already has a child profile (data that would
    /// be orphaned by switching families). One cheap, capped read.
    private func currentFamilyHasData() async throws -> Bool {
        guard let familyId else { return false }
        let snap = try await db.collection("families").document(familyId)
            .collection("babies").limit(to: 1).getDocuments()
        return !snap.documents.isEmpty
    }

    /// Accepts an invite code, looks it up in Firestore, and assigns this user to that family.
    func joinFamily(code: String, uid: String, force: Bool = false) async throws {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        resetStaleCacheIfNeeded(for: uid)
        // Accept either a bare code or a full `momsy://join?code=…` link a user may
        // have pasted; reject anything else so it can't become a `//` Firestore path.
        // Формат проверяется до сети: rules всё равно откажут коду вне канонического
        // вида, а каждый отклонённый `get` стоит биллируемого чтения в `familyExists()`.
        guard let trimmed = JoinDeeplink.normalize(rawCode: code),
              InviteCodeFormat.isValid(trimmed) else {
            throw FamilyError.invalidOrExpiredCode
        }
        let inviteDoc: DocumentSnapshot
        do {
            inviteDoc = try await db.collection("invites").document(trimmed).getDocument()
        } catch let error as NSError where error.domain == FirestoreErrorCode.errorDomain
            && error.code == FirestoreErrorCode.permissionDenied.rawValue {
            // Rules deny `get` for both nonexistent and expired invite codes
            // (resource.data.expiresAt fails to evaluate or is past), so both
            // surface as permission-denied here rather than an empty snapshot.
            throw FamilyError.invalidOrExpiredCode
        }
        guard
            let data = inviteDoc.data(),
            let targetFamilyId = data["familyId"] as? String,
            let expiresAt = (data["expiresAt"] as? Timestamp)?.dateValue(),
            expiresAt > Date()
        else { throw FamilyError.invalidOrExpiredCode }
        let inviteRoleRaw = data["roleRaw"] as? String

        // Already in the target family — idempotent no-op.
        if familyId == targetFamilyId { isReady = true; return }

        // Only pay for the data read when actually switching to a different family.
        let currentFamilyId = familyId
        let switchingFamily = (currentFamilyId != nil && currentFamilyId != targetFamilyId)
        let hasData: Bool
        if switchingFamily, let currentFamilyId {
            do {
                hasData = try await currentFamilyHasData()
            } catch {
                guard Self.classifyMembershipError(error) == .revoked else { throw error }
                let membership = await confirmMembershipHealthGated(
                    familyId: currentFamilyId,
                    uid: uid
                )
                guard Self.canTreatCurrentFamilyAsEmpty(
                    dataReadError: error,
                    confirmedMembership: membership
                ) else { throw error }
                hasData = false
            }
        } else {
            hasData = false
        }
        if FamilyJoinGuard.requiresConfirmation(
            currentFamilyId: familyId, targetFamilyId: targetFamilyId,
            currentFamilyHasData: hasData, force: force
        ) {
            throw FamilyError.wouldAbandonExistingFamily
        }

        // Captured before persist() repoints familyId, so the join notification can
        // carry the id of the family being left.
        let previousFamilyId = familyId

        let currentUser = Auth.auth().currentUser
        let displayName = AccountDisplay.memberName(
            displayName: currentUser?.displayName,
            email: currentUser?.email
        )
        let targetMemberRef = db.collection("families").document(targetFamilyId)
            .collection("members").document(uid)
        let userRef = db.collection("users").document(uid)
        let batch = db.batch()

        // Keep routing and roster membership atomic: users/{uid}.familyId must
        // never commit without the matching member document.
        batch.setData(
            memberDocumentData(
                uid: uid,
                displayName: displayName,
                defaultRoleRaw: inviteRoleRaw ?? FamilyRole.dad.rawValue,
                inviteCode: trimmed,
                includeLifecycleFields: true
            ),
            forDocument: targetMemberRef,
            merge: true
        )

        if let previous = familyId, previous != targetFamilyId {
            let previousMemberRef = db.collection("families").document(previous)
                .collection("members").document(uid)
            batch.deleteDocument(previousMemberRef)
        }

        batch.setData(["familyId": targetFamilyId], forDocument: userRef, merge: true)
        try await batch.commit()

        persist(familyId: targetFamilyId, ownerUid: uid)
        // An explicit invite join supersedes any pending "start fresh" / deletion
        // intent for this uid on this device — otherwise the next launch's
        // suppressed-restore path would delete the freshly created member doc.
        UserDefaultsSuppressedFamilyRestoreStore().clearSuppression(for: uid)
        let pendingStore = UserDefaultsPendingAccountDeletionStore()
        if pendingStore.loadPending() == uid { pendingStore.clearPending() }
        isReady = true
        NotificationCenter.default.post(
            name: .familyDidJoin, object: nil,
            userInfo: previousFamilyId.map { [Self.previousFamilyIdUserInfoKey: $0] }
        )
    }

    /// Removes the abandoned anonymous roster entry after Firebase switches to an
    /// existing provider account. Best-effort because only a parent in that family
    /// may remove another member.
    func removeStaleAnonymousMemberIfNeeded(
        anonymousUid: String,
        signedInUid: String,
        familyId: String?
    ) async {
        guard anonymousUid != signedInUid, let familyId else { return }
        do {
            try await db.collection("families").document(familyId)
                .collection("members").document(anonymousUid)
                .delete()
            Self.log.info("Removed stale anonymous member \(anonymousUid, privacy: .private)")
        } catch {
            Self.log.error("Stale member cleanup failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// True when the caller is the only remaining member (or the roster is empty).
    /// Gates whether account deletion may tear down shared family data.
    func isSoleMember(uid: String) async throws -> Bool {
        guard let familyId else { return true }
        let snap = try await db.collection("families").document(familyId)
            .collection("members").getDocuments()
        let ids = snap.documents.map { $0.documentID }
        return AccountErasureGate.mayTearDownSharedData(memberIds: ids, callerUid: uid)
    }

    /// `permissionDenied` on reading one's OWN member doc means the doc no longer
    /// exists (rules require it to exist for the read) → the caller was removed.
    /// Anything else (offline, unavailable, transient) must not detach.
    nonisolated static func classifyMembershipError(_ error: Error) -> MembershipCheck {
        let ns = error as NSError
        if ns.domain == FirestoreErrorCode.errorDomain,
           ns.code == FirestoreErrorCode.permissionDenied.rawValue {
            return .revoked
        }
        return .unknown
    }

    nonisolated static func canTreatCurrentFamilyAsEmpty(
        dataReadError: Error,
        confirmedMembership: MembershipCheck
    ) -> Bool {
        guard case .revoked = classifyMembershipError(dataReadError),
              case .revoked = confirmedMembership
        else { return false }
        return true
    }

    /// Server-truth check that `uid` still has a member doc in `familyId`.
    private func confirmMembership(familyId: String, uid: String) async -> MembershipCheck {
        do {
            let snap = try await db.collection("families").document(familyId)
                .collection("members").document(uid)
                .getDocument(source: .server)
            return snap.exists ? .member : .revoked
        } catch {
            return Self.classifyMembershipError(error)
        }
    }

    /// Pure gate decision: a raw `.revoked` classification is confirmed only by a
    /// healthy self read; otherwise it degrades to `.unknown`.
    nonisolated static func gatedMembershipCheck(raw: MembershipCheck,
                                                 selfReadSucceeded: Bool) -> MembershipCheck {
        guard raw == .revoked else { return raw }
        return selfReadSucceeded ? .revoked : .unknown
    }

    enum SuppressedRestoreResolution {
        case adoptInviteMembership
        case discardStaleMembership
        case startFresh
    }

    /// Suppressed-restore решение по состоянию member doc. Только invite-join пишет
    /// `inviteCode`, поэтому его наличие доказывает, что членство создано явным
    /// join'ом и не подлежит зачистке при "start fresh".
    nonisolated static func resolveSuppressedRestore(
        memberDocExists: Bool,
        memberHasInviteCode: Bool
    ) -> SuppressedRestoreResolution {
        guard memberDocExists else { return .startFresh }
        return memberHasInviteCode ? .adoptInviteMembership : .discardStaleMembership
    }

    /// Cached-path probe. `permissionDenied` on the member doc is trusted as a
    /// revocation ONLY when a self `users/{uid}` read succeeds in the same probe:
    /// the self read is always permitted by rules, so its success proves the
    /// connection, auth token, and App Check attestation are healthy — leaving
    /// "member doc does not exist" as the only cause of the denial. If the self
    /// read fails too, the denial is environmental → `.unknown`, no detach.
    private func confirmMembershipHealthGated(familyId: String, uid: String) async -> MembershipCheck {
        let check = await confirmMembership(familyId: familyId, uid: uid)
        guard check == .revoked else { return check }
        do {
            _ = try await db.collection("users").document(uid)
                .getDocument(source: .server)
            return Self.gatedMembershipCheck(raw: check, selfReadSucceeded: true)
        } catch {
            Self.log.info("Membership denial not confirmed — self read failed; treating as transient")
            return Self.gatedMembershipCheck(raw: check, selfReadSucceeded: false)
        }
    }

    /// Ordered teardown after a confirmed revocation:
    /// 1) purge local children of the old family (via `onMembershipRevoked`),
    /// 2) clear the routing field so no future sign-in re-adopts the family,
    /// 3) reset local family state, 4) notify the UI.
    private func detachFromRevokedFamily(uid: String, familyId revokedId: String) async {
        Self.log.info("Membership revoked in family \(revokedId, privacy: .public) — detaching")
        await onMembershipRevoked?(revokedId)
        try? await db.collection("users").document(uid)
            .updateData(["familyId": FieldValue.delete()])
        reset()
        NotificationCenter.default.post(name: .familyMembershipRevoked, object: nil)
    }

    func reset() {
        familyId = nil
        isReady = false
        UserDefaults.standard.removeObject(forKey: kFamilyIdDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kFamilyOwnerUidDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kBabyIdDefaultsKey)
    }

    private func persist(familyId id: String, ownerUid uid: String) {
        familyId = id
        UserDefaults.standard.set(id, forKey: kFamilyIdDefaultsKey)
        UserDefaults.standard.set(uid, forKey: kFamilyOwnerUidDefaultsKey)
    }

    private func ensureMemberDocument(
        familyId: String,
        uid: String,
        displayName: String,
        defaultRoleRaw: String,
        inviteCode: String? = nil,
        bootstrapCreator: Bool = false
    ) async throws {
        let ref = db.collection("families").document(familyId)
            .collection("members").document(uid)
        var data = memberDocumentData(
            uid: uid,
            displayName: displayName,
            defaultRoleRaw: defaultRoleRaw,
            inviteCode: inviteCode,
            includeLifecycleFields: inviteCode != nil || bootstrapCreator
        )

        if inviteCode == nil && !bootstrapCreator {
            let snap = try await ref.getDocument()
            let existing = snap.data() ?? [:]
            if existing["id"] as? String == nil {
                data["id"] = UUID().uuidString
            }
            if existing["roleRaw"] as? String == nil {
                data["roleRaw"] = defaultRoleRaw
            }
            if existing["joinedAt"] as? Timestamp == nil {
                data["joinedAt"] = Timestamp(date: Date())
            }
        }
        try await ref.setData(data, merge: true)
    }

    private func memberDocumentData(
        uid: String,
        displayName: String,
        defaultRoleRaw: String,
        inviteCode: String? = nil,
        includeLifecycleFields: Bool
    ) -> [String: Any] {
        var data: [String: Any] = [
            "name": displayName,
            "uid": uid
        ]
        if let inviteCode {
            data["inviteCode"] = inviteCode
        }
        if includeLifecycleFields {
            data["id"] = UUID().uuidString
            data["roleRaw"] = defaultRoleRaw
            data["joinedAt"] = Timestamp(date: Date())
        }
        return data
    }
}
