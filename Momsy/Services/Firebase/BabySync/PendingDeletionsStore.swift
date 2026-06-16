import Foundation

/// Local ledger of entries deleted on this device whose delete may not yet have
/// reached the cloud. Survives launches so an offline delete is retried, and so the
/// launch merge never resurrects an id whose delete is still in flight.
///
/// Keyed by the entry's stable id (its Firestore document id == local UUID) mapped
/// to the subcollection it lived in, so the retry can remove the right cloud doc.
final class PendingDeletionsStore {
    static let shared = PendingDeletionsStore()

    private let key = "pending_deletions_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private var map: [String: String] {
        get { defaults.dictionary(forKey: key) as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: key) }
    }

    func add(id: UUID, collection: String) {
        var m = map
        m[id.uuidString] = collection
        map = m
    }

    func remove(id: UUID) {
        var m = map
        m.removeValue(forKey: id.uuidString)
        map = m
    }

    /// uuid string → subcollection, for retrying the cloud delete.
    func all() -> [String: String] { map }

    /// Ids still pending, used by the merge to avoid resurrecting an in-flight delete.
    func ids() -> Set<UUID> { Set(map.keys.compactMap(UUID.init)) }
}
