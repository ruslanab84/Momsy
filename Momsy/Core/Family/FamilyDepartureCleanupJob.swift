import CryptoKit
import Foundation

enum FamilyDepartureCleanupJob {
    static func documentID(familyID: String, uid: String) -> String {
        let digest = SHA256.hash(data: Data("\(familyID)\0\(uid)".utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func resolvedUID(
        storedUID: String?,
        fallbackUID: String?,
        documentID: String
    ) -> String? {
        [storedUID, fallbackUID, documentID]
            .compactMap { $0 }
            .first { !$0.isEmpty && $0.count <= 128 && !$0.contains("/") }
    }
}
