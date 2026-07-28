import FirebaseFirestore
import Foundation

/// Suppresses exactly one server echo for a live-state write made by this process. The
/// filter is memory-only: after an app restart the initial snapshot is deliberately
/// processed again so an active co-parent session can restore a cleared local cache.
private final class SleepLiveEchoFilter: @unchecked Sendable {
    static let shared = SleepLiveEchoFilter()

    private let lock = NSLock()
    private var pending = Set<String>()

    private func signature(sessionId: String, status: String) -> String {
        "\(sessionId)|\(status)"
    }

    func mark(sessionId: String, status: String) {
        lock.lock(); defer { lock.unlock() }
        pending.insert(signature(sessionId: sessionId, status: status))
    }

    func consumeIfLocalEcho(sessionId: String, status: String) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return pending.remove(signature(sessionId: sessionId, status: status)) != nil
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
            let status = "active"
            SleepLiveEchoFilter.shared.mark(sessionId: id, status: status)
            document.setData(
                ["liveSleep": liveSleepPayload(log: log, id: id, status: status)],
                merge: true
            )
            return
        }

        // A completed manual entry must not stop a running timer. The baby document is
        // already in the local Firestore cache whenever this device owns or mirrors the
        // active timer, so this check costs no billed server read.
        let status = "completed"
        let completedPayload = liveSleepPayload(log: log, id: id, status: status)
        document.getDocument(source: .cache) { snapshot, _ in
            guard let liveSleep = snapshot?.data()?["liveSleep"] as? [String: Any],
                  liveSleep["sessionId"] as? String == id
            else { return }

            SleepLiveEchoFilter.shared.mark(sessionId: id, status: status)
            document.setData(["liveSleep": completedPayload], merge: true)
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

        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let listener = document.addSnapshotListener { snapshot, _ in
                guard let snapshot, snapshot.exists else { return }
                guard !snapshot.metadata.hasPendingWrites else { return }
                guard let liveSleep = snapshot.data()?["liveSleep"] as? [String: Any],
                      liveSleep["updatedAt"] is Timestamp,
                      let sessionId = liveSleep["sessionId"] as? String,
                      let status = liveSleep["status"] as? String
                else { return }

                // The local SwiftData mutation already updated this process's UI. A
                // co-parent device has a separate in-memory filter and is never skipped.
                guard !SleepLiveEchoFilter.shared.consumeIfLocalEcho(
                    sessionId: sessionId,
                    status: status
                ) else { return }
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
            "updatedAt": FieldValue.serverTimestamp(),
        ]
    }
}
