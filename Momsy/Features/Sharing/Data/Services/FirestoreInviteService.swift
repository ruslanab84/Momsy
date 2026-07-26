import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Firestore-backed invite service. Synchronous protocol methods read from UserDefaults cache;
/// Firestore writes happen asynchronously in the background.
final class FirestoreInviteService: InviteServiceProtocol, @unchecked Sendable {
    private var db: Firestore { Firestore.firestore() }
    static let codeKey = "firestore_invite_code_v1"
    static let expiryKey = "firestore_invite_expiry_v1"
    static let familyKey = "firestore_invite_family_v1"
    static let syncedCodeKey = "firestore_invite_synced_code_v1"

    private let codeKey = FirestoreInviteService.codeKey
    private let expiryKey = FirestoreInviteService.expiryKey
    private let familyKey = FirestoreInviteService.familyKey
    private let syncedCodeKey = FirestoreInviteService.syncedCodeKey
    private let defaults  = UserDefaults.standard

    func currentCode() -> String {
        let familyId = defaults.string(forKey: kFamilyIdDefaultsKey)
        let cachedFamilyId = defaults.string(forKey: familyKey)
        if let familyId,
           let code = defaults.string(forKey: codeKey),
           let expiry = defaults.object(forKey: expiryKey) as? Date,
           Self.canReuseCachedInvite(
               cachedCode: code,
               cachedFamilyId: cachedFamilyId,
               currentFamilyId: familyId,
               expiry: expiry
           ) {
            syncIfNeeded(code: code, expiry: expiry, familyId: familyId)
            return code
        }
        return regenerate()
    }

    func inviteURL(for code: String) -> String { "momsy://join?code=\(code)" }

    func expiry() -> Date {
        guard let expiry = defaults.object(forKey: expiryKey) as? Date,
              Self.canReuseCachedInvite(
            cachedCode: defaults.string(forKey: codeKey),
            cachedFamilyId: defaults.string(forKey: familyKey),
            currentFamilyId: defaults.string(forKey: kFamilyIdDefaultsKey),
            expiry: expiry
        ) else { return Date() }
        return expiry
    }

    private var pendingWrite: Task<Void, Error>?

    @discardableResult
    func regenerate() -> String {
        let familyId = defaults.string(forKey: kFamilyIdDefaultsKey)
        let previousCode: String?
        if let familyId, defaults.string(forKey: familyKey) == familyId {
            previousCode = defaults.string(forKey: codeKey)
        } else {
            previousCode = nil
        }
        let code = InviteCodeFormat.generate()
        let exp = Date().addingTimeInterval(86400)
        defaults.set(code, forKey: codeKey)
        defaults.set(exp, forKey: expiryKey)
        if let familyId {
            defaults.set(familyId, forKey: familyKey)
        } else {
            defaults.removeObject(forKey: familyKey)
        }
        defaults.removeObject(forKey: syncedCodeKey)
        pendingWrite = Task {
            guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
            guard let familyId else { throw FamilyError.noFamilyId }
            try await self.writeToFirestore(code: code, expiry: exp, familyId: familyId)
            await self.revokeInvite(previousCode, replacedBy: code)
        }
        return code
    }

    /// Best-effort revocation of the superseded code. Failure is non-fatal — the old
    /// document still self-expires via `expiresAt` (≤24h) and rules deny expired gets.
    private func revokeInvite(_ oldCode: String?, replacedBy newCode: String) async {
        guard let oldCode, oldCode != newCode else { return }
        do {
            try await db.collection("invites").document(oldCode).delete()
        } catch {
            // Old code may belong to a previous family (rules deny) or be gone already.
        }
    }

    /// Awaits the pending Firestore write so the invite code is guaranteed to exist
    /// before the user can share it. Call this from SharingViewModel before showing InviteSheet.
    @discardableResult
    func prepareInvite() async throws -> String {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        let code = currentCode()
        try await pendingWrite?.value
        return code
    }

    @discardableResult
    func regenerateAndSync() async throws -> String {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        let code = regenerate()
        try await pendingWrite?.value
        return code
    }

    func updateInviteRole(code: String, role: FamilyRole) async throws {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        let familyId = defaults.string(forKey: kFamilyIdDefaultsKey)
        let expiry = defaults.object(forKey: expiryKey) as? Date
        guard
            defaults.string(forKey: codeKey) == code,
            Self.canReuseCachedInvite(
                cachedCode: code,
                cachedFamilyId: defaults.string(forKey: familyKey),
                currentFamilyId: familyId,
                expiry: expiry
            ),
            let familyId,
            let expiry
        else { throw FamilyError.invalidOrExpiredCode }
        try await writeToFirestore(
            code: code,
            expiry: expiry,
            roleRaw: role.rawValue,
            familyId: familyId
        )
    }

    private func syncIfNeeded(code: String, expiry: Date, familyId: String) {
        guard CloudSyncConsent.isGranted() else { return }
        guard defaults.string(forKey: syncedCodeKey) != "\(familyId)|\(code)" else { return }
        pendingWrite = Task {
            try await self.writeToFirestore(code: code, expiry: expiry, familyId: familyId)
        }
    }

    private func writeToFirestore(
        code: String,
        expiry: Date,
        roleRaw: String? = nil,
        familyId: String
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw FamilyError.noFamilyId }
        var data: [String: Any] = [
            "familyId": familyId,
            "createdBy": uid,
            "expiresAt": Timestamp(date: expiry)
        ]
        if let roleRaw { data["roleRaw"] = roleRaw }
        try await db.collection("invites").document(code).setData(data, merge: true)
        defaults.set("\(familyId)|\(code)", forKey: syncedCodeKey)
    }

    static func canReuseCachedInvite(
        cachedCode: String?,
        cachedFamilyId: String?,
        currentFamilyId: String?,
        expiry: Date?,
        now: Date = Date()
    ) -> Bool {
        // Код, выданный старой сборкой, короче и новые rules откажут ему в `get`.
        // Отбрасываем его здесь, чтобы `regenerate()` выпустил сильный код.
        guard let cachedCode, InviteCodeFormat.isValid(cachedCode) else { return false }
        guard let currentFamilyId, cachedFamilyId == currentFamilyId, let expiry else {
            return false
        }
        return expiry > now
    }
}
