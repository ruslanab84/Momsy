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
        let code = generateCode()
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
        let code = currentCode()
        try await pendingWrite?.value
        return code
    }

    @discardableResult
    func regenerateAndSync() async throws -> String {
        let code = regenerate()
        try await pendingWrite?.value
        return code
    }

    func updateInviteRole(code: String, role: FamilyRole) async throws {
        let familyId = defaults.string(forKey: kFamilyIdDefaultsKey)
        let expiry = defaults.object(forKey: expiryKey) as? Date
        guard
            defaults.string(forKey: codeKey) == code,
            Self.canReuseCachedInvite(
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
        cachedFamilyId: String?,
        currentFamilyId: String?,
        expiry: Date?,
        now: Date = Date()
    ) -> Bool {
        guard let currentFamilyId, cachedFamilyId == currentFamilyId, let expiry else {
            return false
        }
        return expiry > now
    }

    private func generateCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let suffix = (0..<6).map { _ in chars[Int.random(in: chars.indices)] }
        return "MOMSY-" + String(suffix)
    }
}
