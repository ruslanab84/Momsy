import FirebaseAuth
import FirebaseFirestore
import os

final class BabySyncService {
    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "BabySync")

    private var db: Firestore { Firestore.firestore() }

    /// Both ids are read from UserDefaults (not `FamilyManager`) so the service can build
    /// paths from any actor without hopping. `FamilyManager` keeps `kFamilyIdDefaultsKey`
    /// in sync; `kBabyIdDefaultsKey` is written wherever the local baby profile is saved
    /// (`SwiftDataBabyRepository.saveProfile`) and on cloud writes/discovery below.
    private var familyId: String { defaults.string(forKey: kFamilyIdDefaultsKey) ?? "" }
    /// Honours a background sync's task-local target so the roster download (and queued-write
    /// replay) writes to the child being processed, not the user's currently-selected one.
    private var babyId: String {
        if let override = ActiveBaby.syncTargetOverride { return override.uuidString }
        return defaults.string(forKey: kBabyIdDefaultsKey) ?? ""
    }

    /// A log can only be read/written once we know BOTH the family and the baby.
    private var hasPath: Bool { !familyId.isEmpty && !babyId.isEmpty }

    /// Every log subcollection ever written under `families/{familyId}/babies/{babyId}`.
    /// Must match the `…Logs` names actually written by the view models / `BabySyncRepository`
    /// and read by `CloudSyncDownloader`, plus the legacy `quickLogs` and the `deletions`
    /// tombstones. Used by `deleteAllData()` for full GDPR erasure — a name that does not
    /// match a real collection silently erases nothing. (`momMood` is local-only and never
    /// reaches Firestore, so it is intentionally absent.)
    static let allSubcollections = [
        "feedingLogs", "sleepLogs", "diaperLogs", "stoolLogs", "diaryLogs",
        "walkLogs", "bathLogs", "vitaminLogs", "pumpingLogs", "vaccinationLogs",
        "foodDiaryLogs", "temperatureLogs", "measurementLogs", "doctorVisitLogs",
        "momSleepLogs", "waterIntakeLogs", "leapLogs", "symptomLogs",
        "quickLogs", "deletions",
    ]

    private static let migrationFlagKey = "babysync_perbaby_migration_v1_done"

    /// The store backing the family/baby path. Injectable so tests can isolate it in a
    /// private suite instead of racing other suites on the process-wide `.standard`.
    private let defaults: UserDefaults
    private let cloudSyncAllowed: () -> Bool

    init(
        defaults: UserDefaults = .standard,
        cloudSyncAllowed: @escaping () -> Bool = { CloudSyncConsent.isGranted() }
    ) {
        self.defaults = defaults
        self.cloudSyncAllowed = cloudSyncAllowed
    }

    // MARK: - Path helpers

    /// The per-baby parent document: `families/{familyId}/babies/{babyId}`. Also the
    /// document the baby profile is written to.
    private func babyDoc() -> DocumentReference {
        db.collection("families").document(familyId).collection("babies").document(babyId)
    }

    private func collection(_ name: String) -> CollectionReference {
        babyDoc().collection(name)
    }

    func addLog<T: Encodable>(_ log: T, to subcollection: String) async throws {
        guard cloudSyncAllowed() else { return }
        guard hasPath else { return }
        let ref = collection(subcollection).document()
        let payload = try await encodedPayloadWithAuthor(log)
        // Firestore persists locally and syncs later; awaiting the server ack can hang callers offline.
        ref.setData(payload) { error in
            guard let error else { return }
            Self.log.error("addLog(\(subcollection, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Writes a log using the supplied stable id as the Firestore document id.
    /// Making the doc id == local UUID keeps re-pushes idempotent (overwrite, not duplicate)
    /// and lets the download path dedup entries by id. When the family path isn't ready yet
    /// (onboarding window), the write is queued in `PendingWritesStore` and replayed later
    /// instead of being silently dropped.
    func setLog<T: Encodable>(_ log: T, id: String, to subcollection: String) async throws {
        guard cloudSyncAllowed() else { return }
        guard !id.isEmpty else { return }
        var payload = try await encodedPayloadWithAuthor(log)
        guard hasPath else {
            // `@ServerTimestamp updatedAt` encodes to a `FieldValue` sentinel that `UserDefaults`
            // can't persist; drop it here and let `replayPendingWrites` re-stamp a fresh
            // serverTimestamp. The path is still stamped so replay routes the write to the baby
            // (and family) it belongs to, never to whoever is active at replay time.
            payload.removeValue(forKey: "updatedAt")
            PendingWritesStore.shared.add(collection: subcollection, docId: id,
                                          payload: payload, familyId: familyId, babyId: babyId)
            return
        }
        collection(subcollection).document(id).setData(payload, merge: true) { error in
            guard let error else { return }
            Self.log.error("setLog(\(subcollection, privacy: .public)) failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func encodedPayloadWithAuthor<T: Encodable>(_ log: T) async throws -> [String: Any] {
        let payload = try Firestore.Encoder().encode(log)
        guard SyncAuthorMetadata.requiresAuthor(in: payload) else { return payload }
        return SyncAuthorMetadata.stamp(payload, author: await currentAuthorIdentity())
    }

    private func currentAuthorIdentity() async -> SyncAuthorIdentity? {
        guard FirebaseBootstrapper.isConfigured else { return nil }
        guard let user = Auth.auth().currentUser else { return nil }

        let fallbackName = AccountDisplay.memberName(displayName: user.displayName, email: user.email)
        guard !familyId.isEmpty else {
            return SyncAuthorIdentity(uid: user.uid, displayName: fallbackName)
        }

        if let cachedName = await SyncAuthorIdentityCache.shared.displayName(
            familyId: familyId,
            uid: user.uid
        ) {
            return SyncAuthorIdentity(uid: user.uid, displayName: cachedName)
        }

        if let memberName = try? await memberDisplayName(familyId: familyId, uid: user.uid) {
            await SyncAuthorIdentityCache.shared.setDisplayName(
                memberName,
                familyId: familyId,
                uid: user.uid
            )
            return SyncAuthorIdentity(uid: user.uid, displayName: memberName)
        }

        return SyncAuthorIdentity(uid: user.uid, displayName: fallbackName)
    }

    private func memberDisplayName(familyId: String, uid: String) async throws -> String? {
        let snapshot = try await db.collection("families").document(familyId)
            .collection("members").document(uid)
            .getDocument()
        guard let name = snapshot.data()?["name"] as? String else { return nil }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Deletes & tombstones

    /// Deletes a single log document by its stable id.
    func deleteLog(id: String, from subcollection: String) async throws {
        guard hasPath, !id.isEmpty else { return }
        try await collection(subcollection).document(id).delete()
    }

    /// Records a tombstone so other devices remove the entry and the launch merge
    /// never resurrects it. Keyed by the entry's stable id; collection-agnostic.
    func writeTombstone(id: String) async throws {
        guard hasPath, !id.isEmpty else { return }
        try await collection("deletions").document(id).setData(["deletedAt": Timestamp(date: Date())])
    }

    /// Tombstoned ids deleted on any device, optionally only those at/after `since`.
    /// Ordered by `deletedAt` so the caller can advance a watermark; every tombstone is
    /// written with a `deletedAt`, so the order clause excludes nothing.
    func fetchTombstones(since: Date?, limit: Int = 1000) async throws -> [(id: String, deletedAt: Date)] {
        guard hasPath else { return [] }
        var query: Query = collection("deletions")
            .order(by: "deletedAt", descending: false)
            .limit(to: limit)
        if let since {
            query = collection("deletions")
                .whereField("deletedAt", isGreaterThanOrEqualTo: Timestamp(date: since))
                .order(by: "deletedAt", descending: false)
                .limit(to: limit)
        }
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { doc in
            guard let ts = doc.data()["deletedAt"] as? Timestamp else { return nil }
            return (doc.documentID, ts.dateValue())
        }
    }

    /// Back-compat: ids only, no incremental filter.
    func fetchTombstones(limit: Int = 1000) async throws -> [String] {
        try await fetchTombstones(since: nil, limit: limit).map(\.id)
    }

    /// Propagates a local delete to the cloud: removes the doc and writes a tombstone,
    /// recording the id locally first so an offline delete is retried on next launch.
    func propagateDelete(id: UUID, in subcollection: String) {
        guard hasPath else { return }
        PendingDeletionsStore.shared.add(id: id, collection: subcollection)
        Task {
            do {
                try await deleteLog(id: id.uuidString, from: subcollection)
                try await writeTombstone(id: id.uuidString)
                PendingDeletionsStore.shared.remove(id: id)
            } catch {
                if Self.isPermissionDenied(error) {
                    // Rules will never allow this delete for the current role — a
                    // permanent failure. Drop the entry so the sync loop doesn't
                    // retry it forever; the local delete stays local-only.
                    PendingDeletionsStore.shared.remove(id: id)
                    Self.log.error("propagateDelete(\(subcollection, privacy: .public)) denied by rules — dropping pending entry \(id.uuidString, privacy: .public)")
                } else {
                    Self.log.info("propagateDelete(\(subcollection, privacy: .public)) failed transiently; kept pending")
                }
            }
        }
    }

    /// Rules-denied writes are permanent for the caller's current role/membership —
    /// retrying them forever only burns requests. Everything else (offline,
    /// unavailable, transient backend errors) must stay retryable.
    nonisolated static func isPermissionDenied(_ error: Error) -> Bool {
        let ns = error as NSError
        return ns.domain == FirestoreErrorCode.errorDomain
            && ns.code == FirestoreErrorCode.permissionDenied.rawValue
    }

    /// Decides which baby a queued write replays into, or `nil` to skip it.
    /// - Cross-family guard: a write stamped with a different family is never replayed
    ///   into the current one (e.g. leftovers from a family the user has since left).
    /// - Per-baby routing: a write stamped with a known baby replays into THAT baby;
    ///   one queued before any baby existed falls back to the current baby (single-baby
    ///   onboarding — the only case where the target is genuinely unknown at enqueue).
    static func replayTargetBabyId(entryFamilyId: String, entryBabyId: String,
                                   currentFamilyId: String, currentBabyId: String) -> String? {
        guard !currentFamilyId.isEmpty else { return nil }
        if !entryFamilyId.isEmpty, entryFamilyId != currentFamilyId { return nil }
        let target = entryBabyId.isEmpty ? currentBabyId : entryBabyId
        return target.isEmpty ? nil : target
    }

    /// Replays cloud writes that were queued while the family path wasn't ready. Each
    /// write is routed to the baby/family it was stamped for (see `replayTargetBabyId`)
    /// via a task-local override, so a queued log can never land under the wrong child.
    func replayPendingWrites() async {
        guard cloudSyncAllowed() else { return }
        let currentFamily = familyId
        let currentBaby = babyId
        guard !currentFamily.isEmpty else { return }
        for entry in PendingWritesStore.shared.all() {
            guard
                let targetBaby = Self.replayTargetBabyId(
                    entryFamilyId: entry.familyId, entryBabyId: entry.babyId,
                    currentFamilyId: currentFamily, currentBabyId: currentBaby),
                let targetUUID = UUID(uuidString: targetBaby)
            else { continue }
            do {
                // Re-stamp a server `updatedAt` at replay so the watermark sees the real
                // write time (not the offline enqueue time). The sentinel was stripped at
                // enqueue because `UserDefaults` can't persist a `FieldValue`.
                var payload = SyncAuthorMetadata.stamp(
                    entry.payload,
                    author: await currentAuthorIdentity()
                )
                payload["updatedAt"] = FieldValue.serverTimestamp()
                try await ActiveBaby.$syncTargetOverride.withValue(targetUUID) {
                    try await collection(entry.collection).document(entry.docId)
                        .setData(payload, merge: true)
                }
                PendingWritesStore.shared.remove(docId: entry.docId)
            } catch {
                if Self.isPermissionDenied(error) {
                    // A rules-denied queued write can never succeed for this
                    // role/membership; keeping it would replay-fail on every sync.
                    PendingWritesStore.shared.remove(docId: entry.docId)
                    Self.log.error("replayPendingWrites(\(entry.collection, privacy: .public)) denied by rules — dropping \(entry.docId, privacy: .public)")
                }
                // Transient failures stay pending; the next sync retries.
            }
        }
    }

    /// Retries cloud deletes that didn't complete earlier (e.g. made while offline).
    func retryPendingDeletions() async {
        guard cloudSyncAllowed() else { return }
        for (idStr, collection) in PendingDeletionsStore.shared.all() {
            do {
                try await deleteLog(id: idStr, from: collection)
                try await writeTombstone(id: idStr)
                if let id = UUID(uuidString: idStr) { PendingDeletionsStore.shared.remove(id: id) }
            } catch {
                if Self.isPermissionDenied(error) {
                    if let id = UUID(uuidString: idStr) { PendingDeletionsStore.shared.remove(id: id) }
                    Self.log.error("retryPendingDeletions(\(collection, privacy: .public)) denied by rules — dropping \(idStr, privacy: .public)")
                }
                // Transient failures stay pending for the next sync.
            }
        }
    }

    /// Deletes every document in a subcollection (batched). Used to purge a
    /// retired collection such as the legacy `quickLogs`.
    func deleteAll(in subcollection: String) async throws {
        guard hasPath else { return }
        try await deleteAllDocs(in: collection(subcollection))
    }

    /// Batched delete of every document in an arbitrary collection reference.
    private func deleteAllDocs(in ref: CollectionReference) async throws {
        let snapshot = try await ref.getDocuments()
        let docs = snapshot.documents
        guard !docs.isEmpty else { return }
        // Firestore caps a WriteBatch at 500 ops; chunk well under that.
        for chunk in stride(from: 0, to: docs.count, by: 400) {
            let batch = db.batch()
            for doc in docs[chunk..<min(chunk + 400, docs.count)] {
                batch.deleteDocument(doc.reference)
            }
            try await batch.commit()
        }
    }

    /// Full GDPR erasure of this baby's cloud tree: every log subcollection, the
    /// `profile/info` doc, and the `families/{familyId}/babies/{babyId}` parent document.
    /// Also purges any pre-migration `babies/{familyId}` tree left behind so erasure is
    /// complete even if this device never migrated.
    func deleteAllData() async throws {
        guard hasPath else { return }
        for sub in Self.allSubcollections {
            try await deleteAll(in: sub)
        }
        try await babyDoc().collection("profile").document("info").delete()
        try await babyDoc().delete()
        try await deleteLegacyFamilyTree()
        // Drop this scope's incremental watermarks so a re-add of the family re-seeds from a
        // clean full pull, not an incremental query that would skip the restored docs.
        SyncWatermarkStore().reset(family: familyId, baby: babyId)
    }

    /// Deletes one child from the per-baby family roster without touching the legacy
    /// family-wide tree that full account erasure owns.
    func deleteBaby(id: UUID) async throws {
        guard !familyId.isEmpty else { return }
        try await ActiveBaby.$syncTargetOverride.withValue(id) {
            for sub in Self.allSubcollections {
                try await deleteAll(in: sub)
            }
            try await babyDoc().collection("profile").document("info").delete()
            try await babyDoc().delete()
            SyncWatermarkStore().reset(family: familyId, baby: id.uuidString)
        }
    }

    /// Best-effort removal of the old family-keyed tree (`babies/{familyId}`) that the
    /// per-baby migration copies from but leaves in place during rollout.
    private func deleteLegacyFamilyTree() async throws {
        guard !familyId.isEmpty else { return }
        let oldParent = db.collection("babies").document(familyId)
        for sub in Self.allSubcollections {
            try? await deleteAllDocs(in: oldParent.collection(sub))
        }
        try? await oldParent.collection("profile").document("info").delete()
        try? await oldParent.delete()
    }

    // MARK: - Per-baby migration & discovery

    /// One-time migration from the old family-keyed path (`babies/{familyId}/…`) to the
    /// per-baby path (`families/{familyId}/babies/{babyId}/…`). The canonical babyId is
    /// taken from the old profile doc's `id` field so every device converges on the same
    /// id, then the profile doc and every log subcollection are copied. Idempotent
    /// (`setData` merge); the old tree is left in place so not-yet-updated devices keep
    /// working during rollout. Erasure later cleans it via `deleteLegacyFamilyTree()`.
    func migrateFromFamilyPathIfNeeded() async {
        guard cloudSyncAllowed() else { return }
        guard !defaults.bool(forKey: Self.migrationFlagKey) else { return }
        guard !familyId.isEmpty else { return }

        let oldParent = db.collection("babies").document(familyId)
        let oldProfile = try? await oldParent.getDocument()

        // Resolve the canonical babyId: prefer the old profile doc's `id`, fall back to a
        // babyId already persisted locally (creating device that onboarded post-update).
        let resolvedBabyId: String
        if let snap = oldProfile, snap.exists, let idStr = snap.data()?["id"] as? String, !idStr.isEmpty {
            resolvedBabyId = idStr
        } else if !babyId.isEmpty {
            resolvedBabyId = babyId
        } else {
            // Nothing to migrate (fresh install, or baby not created yet).
            defaults.set(true, forKey: Self.migrationFlagKey)
            return
        }
        defaults.set(resolvedBabyId, forKey: kBabyIdDefaultsKey)

        let newParent = db.collection("families").document(familyId)
            .collection("babies").document(resolvedBabyId)

        do {
            if let data = oldProfile?.data(), !data.isEmpty {
                try await newParent.setData(data, merge: true)
            }
            for sub in Self.allSubcollections {
                try await copyDocs(from: oldParent.collection(sub), to: newParent.collection(sub))
            }
            defaults.set(true, forKey: Self.migrationFlagKey)
        } catch {
            // Leave the flag unset so the migration retries on a future launch.
        }
    }

    private func copyDocs(from source: CollectionReference, to dest: CollectionReference) async throws {
        let docs = try await source.getDocuments().documents
        guard !docs.isEmpty else { return }
        for chunk in stride(from: 0, to: docs.count, by: 400) {
            let batch = db.batch()
            for doc in docs[chunk..<min(chunk + 400, docs.count)] {
                batch.setData(doc.data(), forDocument: dest.document(doc.documentID), merge: true)
            }
            try await batch.commit()
        }
    }

    /// Every babyId in the family roster (`families/{familyId}/babies`). The launch
    /// downloader iterates these so a device pulls *all* children, not just the active
    /// one. Empty when the family isn't set up yet.
    func discoverAllBabyIds() async -> [String] {
        guard !familyId.isEmpty else { return [] }
        let snap = try? await db.collection("families").document(familyId)
            .collection("babies").getDocuments()
        return snap?.documents.map(\.documentID).filter { !$0.isEmpty } ?? []
    }

    // MARK: - Reads

    /// Fires once per SERVER write to `subcollection` newer than `since`. The initial
    /// snapshot is empty (0 reads) — this is a change trigger, not a data source; the
    /// consumer runs the watermark downloader to actually merge. Local pending echoes
    /// are ignored so a device does not resync in response to its own writes.
    func streamLogUpdates(from subcollection: String, since: Date) -> AsyncStream<Void> {
        guard cloudSyncAllowed() else { return AsyncStream { $0.finish() } }
        guard hasPath else { return AsyncStream { $0.finish() } }
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let listener = collection(subcollection)
                .whereField("updatedAt", isGreaterThan: Timestamp(date: since))
                .addSnapshotListener { snapshot, _ in
                    guard let snapshot, !snapshot.documentChanges.isEmpty else { return }
                    guard !snapshot.metadata.hasPendingWrites else { return }
                    continuation.yield(())
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func fetchToday<T: Decodable>(from subcollection: String, dateField: String = "startedAt") async throws -> [T] {
        guard cloudSyncAllowed() else { return [] }
        guard hasPath else { return [] }
        let start = Calendar.current.startOfDay(for: Date())
        let snapshot = try await collection(subcollection)
            .whereField(dateField, isGreaterThanOrEqualTo: Timestamp(date: start))
            .order(by: dateField, descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }

    /// Fetches every doc from a subcollection (newest first), optionally limited to those
    /// at/after `since`. Used by the launch-time download/merge path.
    func fetchAll<T: Decodable>(from subcollection: String,
                                dateField: String,
                                since: Date? = nil,
                                limit: Int = 500) async throws -> [T] {
        guard cloudSyncAllowed() else { return [] }
        guard hasPath else { return [] }
        var all: [T] = []
        var cursor: DocumentSnapshot?

        while true {
            var query: Query
            if let since {
                query = collection(subcollection)
                    .whereField(dateField, isGreaterThanOrEqualTo: Timestamp(date: since))
                    .order(by: dateField, descending: true)
            } else {
                query = collection(subcollection)
                    .order(by: dateField, descending: true)
            }
            query = query.limit(to: limit)
            if let cursor {
                query = query.start(afterDocument: cursor)
            }

            let snapshot = try await query.getDocuments()
            all += snapshot.documents.compactMap { try? $0.data(as: T.self) }
            guard Self.shouldContinuePaginating(pageCount: snapshot.documents.count, pageSize: limit),
                  let lastDocument = snapshot.documents.last else {
                return all
            }
            cursor = lastDocument
        }
    }

    static func shouldContinuePaginating(pageCount: Int, pageSize: Int) -> Bool {
        pageSize > 0 && pageCount == pageSize
    }

    // MARK: - Incremental reads

    /// The `(familyId, babyId)` this service currently targets — honours a background sync's
    /// `ActiveBaby.syncTargetOverride`. Used to scope the sync watermark to the right child.
    func currentScope() -> (familyId: String, babyId: String) { (familyId, babyId) }

    /// Fetches only documents whose server `updatedAt` is at/after `since`, oldest-first.
    /// Single-field range+order on `updatedAt` (auto-indexed). `>=` re-reads the boundary doc;
    /// the merge upsert is idempotent. Ascending order drains a >limit backlog forward without gaps.
    func fetchChanged<T: Decodable>(from subcollection: String,
                                    since: Date,
                                    limit: Int = 500) async throws -> [T] {
        guard cloudSyncAllowed() else { return [] }
        guard hasPath else { return [] }
        let snapshot = try await collection(subcollection)
            .whereField("updatedAt", isGreaterThanOrEqualTo: Timestamp(date: since))
            .order(by: "updatedAt", descending: false)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }

    // MARK: - Baby profile

    /// Writes the baby profile to the `families/{familyId}/babies/{babyId}` PARENT
    /// document. The creating device defines the babyId here (persisting it so log paths
    /// resolve before the first log is written). `merge: true` keeps it alongside any
    /// other parent fields.
    func setBabyProfile(_ profile: BabyProfile) async throws {
        guard cloudSyncAllowed() else { return }
        guard !familyId.isEmpty else { return }
        defaults.set(profile.id.uuidString, forKey: kBabyIdDefaultsKey)
        try babyDoc().setData(from: BabyProfileDTO(from: profile), merge: true)
    }

    /// Reads the baby profile from the per-baby parent document, if present.
    func fetchBabyProfile() async throws -> BabyProfileDTO? {
        guard cloudSyncAllowed() else { return nil }
        guard hasPath else { return nil }
        let snapshot = try await babyDoc().getDocument()
        guard snapshot.exists else { return nil }
        return try? snapshot.data(as: BabyProfileDTO.self)
    }

    func setupBabyProfile(uid: String, displayName: String) async throws {
        guard cloudSyncAllowed() else { return }
        guard hasPath else { return }
        let profileRef = babyDoc().collection("profile").document("info")
        let snapshot = try await profileRef.getDocument()
        if !snapshot.exists {
            try await profileRef.setData([
                "createdAt": Timestamp(date: Date()),
                "members": [["uid": uid, "role": "parent", "name": displayName]]
            ])
        } else {
            try await profileRef.updateData([
                "members": FieldValue.arrayUnion([["uid": uid, "role": "parent", "name": displayName]])
            ])
        }
    }
}
