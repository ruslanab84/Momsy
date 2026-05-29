import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Firestore-backed invite service. Synchronous protocol methods read from UserDefaults cache;
/// Firestore writes happen asynchronously in the background.
final class FirestoreInviteService: InviteServiceProtocol {
    private var db: Firestore { Firestore.firestore() }
    private let codeKey   = "firestore_invite_code_v1"
    private let expiryKey = "firestore_invite_expiry_v1"
    private let defaults  = UserDefaults.standard

    func currentCode() -> String {
        if let code = defaults.string(forKey: codeKey),
           let expiry = defaults.object(forKey: expiryKey) as? Date,
           expiry > Date() {
            return code
        }
        return regenerate()
    }

    func inviteURL(for code: String) -> String { "momsy://join?code=\(code)" }

    func expiry() -> Date {
        (defaults.object(forKey: expiryKey) as? Date) ?? Date().addingTimeInterval(86400)
    }

    @discardableResult
    func regenerate() -> String {
        let code = generateCode()
        let exp = Date().addingTimeInterval(86400)
        defaults.set(code, forKey: codeKey)
        defaults.set(exp, forKey: expiryKey)
        Task { await self.writeToFirestore(code: code, expiry: exp) }
        return code
    }

    private func writeToFirestore(code: String, expiry: Date) async {
        guard
            let familyId = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey),
            let uid = Auth.auth().currentUser?.uid
        else { return }
        try? await db.collection("invites").document(code).setData([
            "familyId": familyId,
            "createdBy": uid,
            "expiresAt": Timestamp(date: expiry)
        ])
    }

    private func generateCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return "MOMSY-" + String((0..<6).map { _ in chars.randomElement()! })
    }
}
