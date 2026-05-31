import FirebaseFirestore

final class BabySyncService {
    private var db: Firestore { Firestore.firestore() }
    private var babyId: String { FamilyManager.shared.familyId ?? "" }

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
