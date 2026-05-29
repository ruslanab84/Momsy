import Foundation
import FirebaseFirestore

final class FirestoreFeedingRepository: FeedingRepository {
    private let db = Firestore.firestore()

    private func col() throws -> CollectionReference {
        guard let id = UserDefaults.standard.string(forKey: kFamilyIdDefaultsKey) else {
            throw FamilyError.noFamilyId
        }
        return db.collection("families").document(id).collection("feeding")
    }

    func getEntries(for date: Date) async throws -> [FeedingEntry] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return try await getEntries(from: start, to: end)
    }

    func getEntries(from startDate: Date, to endDate: Date) async throws -> [FeedingEntry] {
        let snap = try await col()
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("date", isLessThan: Timestamp(date: endDate))
            .order(by: "date")
            .getDocuments()
        return snap.documents.compactMap { FeedingEntry(firestoreData: $0.data()) }
    }

    func add(_ entry: FeedingEntry) async throws {
        try await col().document(entry.id.uuidString).setData(entry.toFirestoreData())
    }

    func delete(id: UUID) async throws {
        try await col().document(id.uuidString).delete()
    }
}

extension FeedingEntry {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "date": Timestamp(date: date),
            "durationSeconds": durationSeconds,
            "sideRaw": side.rawValue
        ]
        if let mood { data["mood"] = mood }
        if let ml = milliliters { data["milliliters"] = ml }
        return data
    }

    init?(firestoreData data: [String: Any]) {
        guard
            let idStr = data["id"] as? String,
            let id = UUID(uuidString: idStr),
            let ts = data["date"] as? Timestamp,
            let sideRaw = data["sideRaw"] as? String,
            let duration = data["durationSeconds"] as? Int
        else { return nil }
        self.id = id
        self.date = ts.dateValue()
        self.durationSeconds = duration
        self.side = FeedingSide(rawValue: sideRaw) ?? .left
        self.mood = data["mood"] as? String
        self.milliliters = data["milliliters"] as? Int
    }
}
