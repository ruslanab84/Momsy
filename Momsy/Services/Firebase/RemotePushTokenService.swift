import FirebaseAuth
import FirebaseFirestore
import Foundation
import os

@MainActor
final class RemotePushTokenService {
    static let shared = RemotePushTokenService()

    private static let installationIdKey = "remote_push_installation_id_v1"
    private let logger = Logger(subsystem: "RuslanAbd.Momsy", category: "RemotePush")
    private var applicationToken: String?

    private init() {}

    func receiveApplicationToken(_ data: Data) {
        applicationToken = Self.hex(data)
        republishApplicationTokenIfAvailable()
    }

    func republishApplicationTokenIfAvailable() {
        guard let applicationToken,
              let scope = currentScope() else { return }
        let payload: [String: Any] = [
            "installationId": installationId,
            "ownerUid": scope.uid,
            "environment": Self.environment,
            "token": applicationToken,
            "updatedAt": FieldValue.serverTimestamp(),
        ]
        write(
            payload,
            to: Firestore.firestore().collection("families").document(scope.familyId)
                .collection("devicePushTokens").document(installationId)
        )
    }

    func publishLiveActivity(
        token: Data,
        activityId: String,
        familyId: String,
        babyId: UUID,
        sleepLogId: UUID,
        effectiveStartDate: Date
    ) {
        guard let scope = currentScope(), scope.familyId == familyId else { return }
        let payload: [String: Any] = [
            "activityId": activityId,
            "ownerUid": scope.uid,
            "babyId": babyId.uuidString,
            "sleepLogId": sleepLogId.uuidString,
            "kind": "sleep",
            "environment": Self.environment,
            "token": Self.hex(token),
            "effectiveStartDate": Timestamp(date: effectiveStartDate),
            "updatedAt": FieldValue.serverTimestamp(),
        ]
        write(
            payload,
            to: Firestore.firestore().collection("families").document(familyId)
                .collection("liveActivityTokens").document(activityId)
        )
    }

    func revokeLiveActivity(activityId: String, familyId: String?) {
        guard let familyId, !activityId.isEmpty,
              let scope = currentScope(), scope.familyId == familyId else { return }
        Firestore.firestore().collection("families").document(familyId)
            .collection("liveActivityTokens").document(activityId)
            .delete { [logger] error in
                if let error {
                    logger.error("Live Activity token revoke failed: \(error.localizedDescription, privacy: .public)")
                }
            }
    }

    private func write(_ payload: [String: Any], to reference: DocumentReference) {
        reference.setData(payload, merge: true) { [logger] error in
            if let error {
                logger.error("Push token publish failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func currentScope() -> (uid: String, familyId: String)? {
        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let uid = Auth.auth().currentUser?.uid,
              let familyId = FamilyManager.shared.familyId,
              !familyId.isEmpty else { return nil }
        return (uid, familyId)
    }

    private var installationId: String {
        if let existing = UserDefaults.standard.string(forKey: Self.installationIdKey),
           !existing.isEmpty {
            return existing
        }
        let created = UUID().uuidString
        UserDefaults.standard.set(created, forKey: Self.installationIdKey)
        return created
    }

    private static func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    private static var environment: String {
#if DEBUG
        "sandbox"
#else
        "production"
#endif
    }
}
