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
