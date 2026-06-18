import FirebaseFirestore

final class BabySyncService {
    private var db: Firestore { Firestore.firestore() }

    /// Both ids are read from UserDefaults (not `FamilyManager`) so the service can build
    /// paths from any actor without hopping. `FamilyManager` keeps `kFamilyIdDefaultsKey`
    /// in sync; `kBabyIdDefaultsKey` is written wherever the local baby profile is saved
    /// (`SwiftDataBabyRepository.saveProfile`) and on cloud writes/discovery below.
    private var familyId: String { UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey) ?? "" }
    private var babyId: String { UserDefaults.standard.string(forKey: kBabyIdDefaultsKey) ?? "" }

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

    init() {}

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
        guard hasPath else { return }
        let ref = collection(subcollection).document()
        try ref.setData(from: log)
    }

    /// Writes a log using the supplied stable id as the Firestore document id.
    /// Making the doc id == local UUID keeps re-pushes idempotent (overwrite, not duplicate)
    /// and lets the download path dedup entries by id.
    func setLog<T: Encodable>(_ log: T, id: String, to subcollection: String) async throws {
        guard hasPath, !id.isEmpty else { return }
        try collection(subcollection).document(id).setData(from: log, merge: true)
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

    /// Reads tombstoned ids (entries deleted on any device).
    func fetchTombstones(limit: Int = 1000) async throws -> [String] {
        guard hasPath else { return [] }
        let snapshot = try await collection("deletions").limit(to: limit).getDocuments()
        return snapshot.documents.map(\.documentID)
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
                // Leave it pending; the launch merge will retry.
            }
        }
    }

    /// Retries cloud deletes that didn't complete earlier (e.g. made while offline).
    func retryPendingDeletions() async {
        for (idStr, collection) in PendingDeletionsStore.shared.all() {
            do {
                try await deleteLog(id: idStr, from: collection)
                try await writeTombstone(id: idStr)
                if let id = UUID(uuidString: idStr) { PendingDeletionsStore.shared.remove(id: id) }
            } catch {
                // keep pending
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
        guard !UserDefaults.standard.bool(forKey: Self.migrationFlagKey) else { return }
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
            UserDefaults.standard.set(true, forKey: Self.migrationFlagKey)
            return
        }
        UserDefaults.standard.set(resolvedBabyId, forKey: kBabyIdDefaultsKey)

        let newParent = db.collection("families").document(familyId)
            .collection("babies").document(resolvedBabyId)

        do {
            if let data = oldProfile?.data(), !data.isEmpty {
                try await newParent.setData(data, merge: true)
            }
            for sub in Self.allSubcollections {
                try await copyDocs(from: oldParent.collection(sub), to: newParent.collection(sub))
            }
            UserDefaults.standard.set(true, forKey: Self.migrationFlagKey)
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

    /// For a device that joined an already-migrated family and has no local baby yet:
    /// discover the babyId from the family's baby roster and persist it so the log paths
    /// resolve. Single-baby today, so the first roster entry is the baby.
    func discoverAndPersistBabyId() async {
        guard babyId.isEmpty, !familyId.isEmpty else { return }
        let snap = try? await db.collection("families").document(familyId)
            .collection("babies").limit(to: 1).getDocuments()
        if let docId = snap?.documents.first?.documentID, !docId.isEmpty {
            UserDefaults.standard.set(docId, forKey: kBabyIdDefaultsKey)
        }
    }

    // MARK: - Reads

    func streamLogs<T: Decodable>(
        from subcollection: String,
        limit: Int = 50
    ) -> AsyncStream<[T]> {
        guard hasPath else { return AsyncStream { $0.finish() } }
        return AsyncStream { continuation in
            let listener = collection(subcollection)
                .order(by: "startedAt", descending: true)
                .limit(to: limit)
                .addSnapshotListener { snapshot, _ in
                    guard let docs = snapshot?.documents else { return }
                    let items = docs.compactMap { try? $0.data(as: T.self) }
                    continuation.yield(items)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func streamLogsByField<T: Decodable>(
        from subcollection: String,
        orderField: String,
        limit: Int = 50
    ) -> AsyncStream<[T]> {
        guard hasPath else { return AsyncStream { $0.finish() } }
        return AsyncStream { continuation in
            let listener = collection(subcollection)
                .order(by: orderField, descending: true)
                .limit(to: limit)
                .addSnapshotListener { snapshot, _ in
                    guard let docs = snapshot?.documents else { return }
                    let items = docs.compactMap { try? $0.data(as: T.self) }
                    continuation.yield(items)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func fetchToday<T: Decodable>(from subcollection: String, dateField: String = "startedAt") async throws -> [T] {
        guard hasPath else { return [] }
        let start = Calendar.current.startOfDay(for: Date())
        let snapshot = try await collection(subcollection)
            .whereField(dateField, isGreaterThanOrEqualTo: Timestamp(date: start))
            .order(by: dateField, descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }

    /// Fetches all docs from a subcollection (newest first), optionally limited to those
    /// at/after `since`. Used by the launch-time download/merge path.
    func fetchAll<T: Decodable>(from subcollection: String,
                                dateField: String,
                                since: Date? = nil,
                                limit: Int = 500) async throws -> [T] {
        guard hasPath else { return [] }
        var query: Query = collection(subcollection)
            .order(by: dateField, descending: true)
            .limit(to: limit)
        if let since {
            query = collection(subcollection)
                .whereField(dateField, isGreaterThanOrEqualTo: Timestamp(date: since))
                .order(by: dateField, descending: true)
                .limit(to: limit)
        }
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }

    // MARK: - Baby profile

    /// Writes the baby profile to the `families/{familyId}/babies/{babyId}` PARENT
    /// document. The creating device defines the babyId here (persisting it so log paths
    /// resolve before the first log is written). `merge: true` keeps it alongside any
    /// other parent fields.
    func setBabyProfile(_ profile: BabyProfile) async throws {
        guard !familyId.isEmpty else { return }
        UserDefaults.standard.set(profile.id.uuidString, forKey: kBabyIdDefaultsKey)
        try babyDoc().setData(from: BabyProfileDTO(from: profile), merge: true)
    }

    /// Reads the baby profile from the per-baby parent document, if present.
    func fetchBabyProfile() async throws -> BabyProfileDTO? {
        guard hasPath else { return nil }
        let snapshot = try await babyDoc().getDocument()
        guard snapshot.exists else { return nil }
        return try? snapshot.data(as: BabyProfileDTO.self)
    }

    func setupBabyProfile(uid: String, displayName: String) async throws {
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
