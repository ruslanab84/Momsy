import FirebaseFirestore
import Foundation

/// A per-install identifier lets the document listener ignore writes produced by this
/// exact device while still receiving updates from another iPhone signed into the same
/// Firebase account.
private enum SleepLiveDeviceIdentity {
    private static let key = "babysync_live_sleep_device_id_v1"

    static func current(defaults: UserDefaults = .standard) -> String {
        if let existing = defaults.string(forKey: key), !existing.isEmpty {
            return existing
        }
        let created = UUID().uuidString
        defaults.set(created, forKey: key)
        return created
    }
}

extension BabySyncService {
    /// A concrete overload for sleep DTOs. Existing call sites continue using `setLog`,
    /// but sleep timer writes additionally maintain one tiny live-state map on the baby
    /// document. Manual completed entries do not touch the live state because their id
    /// does not match the currently active session cached on this device.
    func setLog(_ log: SleepLogDTO, id: String, to subcollection: String) async throws {
        try await writeGenericLog(log, id: id, to: subcollection)

        guard subcollection == "sleepLogs",
              FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let document = liveSleepDocument()
        else { return }

        if log.endedAt == nil {
            document.setData(
                ["liveSleep": liveSleepPayload(log: log, id: id, status: "active")],
                merge: true
            )
            return
        }

        // A completed manual entry must not stop a running timer. The baby document is
        // already in the local Firestore cache whenever this device owns or mirrors the
        // active timer, so this check costs no billed server read.
        document.getDocument(source: .cache) { [weak document] snapshot, _ in
            guard let document,
                  let liveSleep = snapshot?.data()?["liveSleep"] as? [String: Any],
                  liveSleep["sessionId"] as? String == id
            else { return }

            document.setData(
                ["liveSleep": self.liveSleepPayload(log: log, id: id, status: "completed")],
                merge: true
            )
        }
    }

    /// Foreground-only stream backed by one baby document rather than a query over the
    /// sleep history collection. The initial snapshot acts as catch-up when a co-parent
    /// started or stopped sleep while this device was backgrounded.
    func streamSleepLiveUpdates() -> AsyncStream<Void> {
        guard FirebaseBootstrapper.isConfigured,
              CloudSyncConsent.isGranted(),
              let document = liveSleepDocument()
        else { return AsyncStream { $0.finish() } }

        let localDeviceId = SleepLiveDeviceIdentity.current()
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let listener = document.addSnapshotListener { snapshot, _ in
                guard let snapshot, snapshot.exists else { return }
                guard !snapshot.metadata.hasPendingWrites else { return }
                guard let liveSleep = snapshot.data()?["liveSleep"] as? [String: Any],
                      liveSleep["updatedAt"] is Timestamp
                else { return }

                // The local SwiftData write already updated this device's UI. Avoid a
                // redundant delta query for our own Start/Stop, but do not suppress a
                // second device that happens to use the same Firebase account.
                guard liveSleep["originDeviceId"] as? String != localDeviceId else { return }
                continuation.yield(())
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    private func writeGenericLog<T: Encodable>(
        _ log: T,
        id: String,
        to subcollection: String
    ) async throws {
        // `T` is generic here, so overload resolution deliberately selects the original
        // generic `BabySyncService.setLog` implementation rather than recursing into the
        // concrete `SleepLogDTO` overload above.
        try await setLog(log, id: id, to: subcollection)
    }

    private func liveSleepDocument() -> DocumentReference? {
        let scope = currentScope()
        guard !scope.familyId.isEmpty, !scope.babyId.isEmpty else { return nil }
        return Firestore.firestore()
            .collection("families").document(scope.familyId)
            .collection("babies").document(scope.babyId)
    }

    private func liveSleepPayload(
        log: SleepLogDTO,
        id: String,
        status: String
    ) -> [String: Any] {
        [
            "sessionId": id,
            "status": status,
            "isActive": status == "active",
            "startedAt": log.startedAt,
            "endedAt": log.endedAt ?? NSNull(),
            "originDeviceId": SleepLiveDeviceIdentity.current(),
            "updatedAt": FieldValue.serverTimestamp(),
        ]
    }
}
