import FirebaseFirestore

final class BabySyncService {
    private var db: Firestore { Firestore.firestore() }
    private var babyId: String { FamilyManager.shared.familyId ?? "" }

    /// Every log subcollection ever written under `babies/{babyId}`. Must match the
    /// `…Logs` names actually written by the view models / `BabySyncRepository` and read
    /// by `CloudSyncDownloader`, plus the legacy `quickLogs` and the `deletions`
    /// tombstones. Used by `deleteAllData()` for full GDPR erasure — a name that does
    /// not match a real collection silently erases nothing. (`momMood` is local-only and
    /// never reaches Firestore, so it is intentionally absent.)
    static let allSubcollections = [
        "feedingLogs", "sleepLogs", "diaperLogs", "stoolLogs", "diaryLogs",
        "walkLogs", "bathLogs", "vitaminLogs", "pumpingLogs", "vaccinationLogs",
        "foodDiaryLogs", "temperatureLogs", "measurementLogs", "doctorVisitLogs",
        "momSleepLogs", "waterIntakeLogs", "leapLogs", "symptomLogs",
        "quickLogs", "deletions",
    ]

    init() {}

    private func collection(_ name: String) -> CollectionReference {
        db.collection("babies").document(babyId).collection(name)
    }

    func addLog<T: Encodable>(_ log: T, to subcollection: String) async throws {
        guard !babyId.isEmpty else { return }
        let ref = collection(subcollection).document()
        try ref.setData(from: log)
    }

    /// Writes a log using the supplied stable id as the Firestore document id.
    /// Making the doc id == local UUID keeps re-pushes idempotent (overwrite, not duplicate)
    /// and lets the download path dedup entries by id.
    func setLog<T: Encodable>(_ log: T, id: String, to subcollection: String) async throws {
        guard !babyId.isEmpty, !id.isEmpty else { return }
        try collection(subcollection).document(id).setData(from: log, merge: true)
    }

    // MARK: - Deletes & tombstones

    /// Deletes a single log document by its stable id.
    func deleteLog(id: String, from subcollection: String) async throws {
        guard !babyId.isEmpty, !id.isEmpty else { return }
        try await collection(subcollection).document(id).delete()
    }

    /// Records a tombstone so other devices remove the entry and the launch merge
    /// never resurrects it. Keyed by the entry's stable id; collection-agnostic.
    func writeTombstone(id: String) async throws {
        guard !babyId.isEmpty, !id.isEmpty else { return }
        try await collection("deletions").document(id).setData(["deletedAt": Timestamp(date: Date())])
    }

    /// Reads tombstoned ids (entries deleted on any device).
    func fetchTombstones(limit: Int = 1000) async throws -> [String] {
        guard !babyId.isEmpty else { return [] }
        let snapshot = try await collection("deletions").limit(to: limit).getDocuments()
        return snapshot.documents.map(\.documentID)
    }

    /// Propagates a local delete to the cloud: removes the doc and writes a tombstone,
    /// recording the id locally first so an offline delete is retried on next launch.
    func propagateDelete(id: UUID, in subcollection: String) {
        guard !babyId.isEmpty else { return }
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
        guard !babyId.isEmpty else { return }
        let snapshot = try await collection(subcollection).getDocuments()
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
    /// `profile/info` doc, and the `babies/{babyId}` parent document itself.
    func deleteAllData() async throws {
        guard !babyId.isEmpty else { return }
        for sub in Self.allSubcollections {
            try await deleteAll(in: sub)
        }
        try await db.collection("babies").document(babyId)
            .collection("profile").document("info").delete()
        try await db.collection("babies").document(babyId).delete()
    }

    func streamLogs<T: Decodable>(
        from subcollection: String,
        limit: Int = 50
    ) -> AsyncStream<[T]> {
        guard !babyId.isEmpty else { return AsyncStream { $0.finish() } }
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
        guard !babyId.isEmpty else { return AsyncStream { $0.finish() } }
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
        guard !babyId.isEmpty else { return [] }
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
        guard !babyId.isEmpty else { return [] }
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

    /// Writes the baby profile to the `babies/{babyId}` PARENT document. This is the
    /// document Firestore otherwise shows as "does not exist" (a ghost parent created by
    /// its subcollections). `merge: true` keeps it alongside any other parent fields.
    func setBabyProfile(_ profile: BabyProfile) async throws {
        guard !babyId.isEmpty else { return }
        try db.collection("babies").document(babyId)
            .setData(from: BabyProfileDTO(from: profile), merge: true)
    }

    /// Reads the baby profile from the `babies/{babyId}` parent document, if present.
    func fetchBabyProfile() async throws -> BabyProfileDTO? {
        guard !babyId.isEmpty else { return nil }
        let snapshot = try await db.collection("babies").document(babyId).getDocument()
        guard snapshot.exists else { return nil }
        return try? snapshot.data(as: BabyProfileDTO.self)
    }

    func setupBabyProfile(uid: String, displayName: String) async throws {
        guard !babyId.isEmpty else { return }
        let profileRef = db.collection("babies").document(babyId).collection("profile").document("info")
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
