import Foundation
import FirebaseFirestore

/// Local ledger of cloud writes that could not be sent because the family path
/// (`familyId`/`babyId`) wasn't ready yet — the onboarding window. Mirrors
/// `PendingDeletionsStore`: survives launches and is replayed by `BabySyncService`
/// once the path resolves, so a log created before setup still reaches the cloud.
///
/// Payloads are stored plist-safe: Firestore `Timestamp` values are normalized to
/// `Date` (Firestore converts them back to `Timestamp` on `setData`).
final class PendingWritesStore {
    static let shared = PendingWritesStore()

    struct Entry {
        let collection: String
        let docId: String
        let payload: [String: Any]
        /// The path the write was made for, captured at enqueue. Replay uses these to
        /// send the write to the baby/family it actually belongs to — never to whichever
        /// child happens to be active at replay time. Empty when unknown at enqueue.
        let familyId: String
        let babyId: String
    }

    private let key = "pending_writes_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private var raw: [[String: Any]] {
        get { defaults.array(forKey: key) as? [[String: Any]] ?? [] }
        set { defaults.set(newValue, forKey: key) }
    }

    /// Enqueues a write, replacing any earlier pending write with the same docId so
    /// only the latest payload for an id is kept (matches `setData(merge:)` semantics).
    func add(collection: String, docId: String, payload: [String: Any],
             familyId: String, babyId: String) {
        let safe = (Self.plistSafe(payload) as? [String: Any]) ?? [:]
        var items = raw.filter { ($0["docId"] as? String) != docId }
        items.append(["collection": collection, "docId": docId, "payload": safe,
                      "familyId": familyId, "babyId": babyId])
        raw = items
    }

    func all() -> [Entry] {
        raw.compactMap { dict in
            guard
                let collection = dict["collection"] as? String,
                let docId = dict["docId"] as? String,
                let payload = dict["payload"] as? [String: Any]
            else { return nil }
            return Entry(collection: collection, docId: docId, payload: payload,
                         familyId: dict["familyId"] as? String ?? "",
                         babyId: dict["babyId"] as? String ?? "")
        }
    }

    func remove(docId: String) {
        raw = raw.filter { ($0["docId"] as? String) != docId }
    }

    func removeAll(forBaby id: UUID) {
        raw = raw.filter { ($0["babyId"] as? String) != id.uuidString }
    }

    func clear() { defaults.removeObject(forKey: key) }

    /// Recursively replaces Firestore `Timestamp` with `Date` so the payload is
    /// plist-codable for UserDefaults persistence.
    static func plistSafe(_ value: Any) -> Any {
        switch value {
        case let ts as Timestamp:       return ts.dateValue()
        case let dict as [String: Any]: return dict.mapValues { plistSafe($0) }
        case let array as [Any]:        return array.map { plistSafe($0) }
        default:                        return value
        }
    }
}
