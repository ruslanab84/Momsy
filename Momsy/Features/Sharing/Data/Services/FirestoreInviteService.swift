import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Firestore-backed invite service. Synchronous protocol methods read from UserDefaults cache.
@MainActor
final class FirestoreInviteService: InviteServiceProtocol, @unchecked Sendable {
    private var db: Firestore { Firestore.firestore() }
    static let codeKey = "firestore_invite_code_v1"
    static let expiryKey = "firestore_invite_expiry_v1"
    static let familyKey = "firestore_invite_family_v1"
    static let roleKey = "firestore_invite_role_v1"
    static let syncedCodeKey = "firestore_invite_synced_code_v1"

    private let codeKey = FirestoreInviteService.codeKey
    private let expiryKey = FirestoreInviteService.expiryKey
    private let familyKey = FirestoreInviteService.familyKey
    private let roleKey = FirestoreInviteService.roleKey
    private let syncedCodeKey = FirestoreInviteService.syncedCodeKey
    private let defaults  = UserDefaults.standard

    func currentCode() -> String {
        defaults.string(forKey: codeKey) ?? ""
    }

    func currentRole() -> FamilyRole {
        defaults.string(forKey: roleKey)
            .flatMap(FamilyRole.init(storedRawValue:)) ?? .dad
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

    @discardableResult
    func prepareInvite(defaultRole: FamilyRole) async throws -> String {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        let familyId = defaults.string(forKey: kFamilyIdDefaultsKey)
        let code = defaults.string(forKey: codeKey)
        let expiry = defaults.object(forKey: expiryKey) as? Date
        if let familyId,
           let code,
           Self.canReuseCachedInvite(
               cachedCode: code,
               cachedFamilyId: defaults.string(forKey: familyKey),
               currentFamilyId: familyId,
               expiry: expiry
           ) {
            do {
                let snapshot = try await db.collection("invites").document(code)
                    .getDocument(source: .server)
                if let data = snapshot.data(),
                   data["familyId"] as? String == familyId,
                   let serverExpiry = (data["expiresAt"] as? Timestamp)?.dateValue(),
                   serverExpiry > Date(),
                   let roleRaw = data["roleRaw"] as? String,
                   let role = FamilyRole(storedRawValue: roleRaw) {
                    defaults.set(serverExpiry, forKey: expiryKey)
                    defaults.set(role.rawValue, forKey: roleKey)
                    defaults.set("\(familyId)|\(code)", forKey: syncedCodeKey)
                    return code
                }
            } catch let error as NSError where error.domain == FirestoreErrorCode.errorDomain
                && error.code == FirestoreErrorCode.permissionDenied.rawValue {
                // Missing, expired and consumed invites are hidden by rules.
            }
        }
        return try await issueInvite(role: defaultRole)
    }

    @discardableResult
    func issueInvite(role: FamilyRole) async throws -> String {
        guard CloudSyncConsent.isGranted() else { throw AuthError.cloudSyncConsentRequired }
        guard let familyId = defaults.string(forKey: kFamilyIdDefaultsKey) else {
            throw FamilyError.noFamilyId
        }
        guard let uid = Auth.auth().currentUser?.uid else { throw FamilyError.noFamilyId }
        let oldCode = defaults.string(forKey: familyKey) == familyId
            ? defaults.string(forKey: codeKey)
            : nil
        let code = InviteCodeFormat.generate()
        let expiry = Date().addingTimeInterval(86400)
        let data: [String: Any] = [
            "familyId": familyId,
            "createdBy": uid,
            "expiresAt": Timestamp(date: expiry),
            "roleRaw": role.rawValue
        ]
        // Ограниченное ожидание: `try await setData` офлайн не возвращает управление,
        // и весь экран «Поделиться» зависал со спиннером навсегда. Здесь ack нужен
        // по-настоящему — показывать QR для несуществующего инвайта нельзя, — поэтому
        // ожидание не убирается, а ограничивается и превращается в видимую ошибку.
        let invites = db.collection("invites")
        let batch = db.batch()
        batch.setData(data, forDocument: invites.document(code))
        if let oldCode, oldCode != code {
            batch.deleteDocument(invites.document(oldCode))
        }
        let previousCode = defaults.object(forKey: codeKey)
        let previousExpiry = defaults.object(forKey: expiryKey)
        let previousFamily = defaults.object(forKey: familyKey)
        let previousRole = defaults.object(forKey: roleKey)
        let previousSyncedCode = defaults.object(forKey: syncedCodeKey)
        cache(code: code, expiry: expiry, familyId: familyId, role: role)
        do {
            try await FirestoreAck.confirm(timeout: Self.ackTimeout) { done in
                batch.commit(completion: done)
            }
        } catch FirestoreAckError.notConfirmed {
            // The batch remains queued; keep its identity so a late commit is recoverable.
            throw FirestoreAckError.notConfirmed
        } catch {
            restore(previousCode, forKey: codeKey)
            restore(previousExpiry, forKey: expiryKey)
            restore(previousFamily, forKey: familyKey)
            restore(previousRole, forKey: roleKey)
            restore(previousSyncedCode, forKey: syncedCodeKey)
            throw error
        }
        return code
    }

    private func cache(code: String, expiry: Date, familyId: String, role: FamilyRole) {
        defaults.set(code, forKey: codeKey)
        defaults.set(expiry, forKey: expiryKey)
        defaults.set(familyId, forKey: familyKey)
        defaults.set(role.rawValue, forKey: roleKey)
        defaults.set("\(familyId)|\(code)", forKey: syncedCodeKey)
    }

    private func restore(_ value: Any?, forKey key: String) {
        if let value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    /// Столько ждём подтверждения бэкендом, прежде чем показать пользователю ошибку.
    /// Хватает на медленную сотовую сеть и при этом не превращается в «зависание».
    static let ackTimeout: TimeInterval = 10

    static func canReuseCachedInvite(
        cachedCode: String?,
        cachedFamilyId: String?,
        currentFamilyId: String?,
        expiry: Date?,
        now: Date = Date()
    ) -> Bool {
        // Код, выданный старой сборкой, короче и новые rules откажут ему в `get`.
        // Отбрасываем его здесь, чтобы `issueInvite` выпустил сильный код.
        guard let cachedCode, InviteCodeFormat.isValid(cachedCode) else { return false }
        guard let currentFamilyId, cachedFamilyId == currentFamilyId, let expiry else {
            return false
        }
        return expiry > now
    }
}
