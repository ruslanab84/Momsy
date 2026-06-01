import Foundation

extension Sequence {
    /// Returns the elements de-duplicated by `key`, keeping the first occurrence.
    ///
    /// Defensive guard for persisted rows that share a logical id. The Firestore
    /// download/merge path upserts by id, but a record could still land twice
    /// (e.g. an older local row plus a freshly downloaded copy). De-duplicating at
    /// read time keeps query results clean without physically deleting rows —
    /// which would be unsafe, since the same logical record may be re-downloaded.
    func uniqued<Key: Hashable>(by key: (Element) -> Key) -> [Element] {
        var seen = Set<Key>()
        return filter { seen.insert(key($0)).inserted }
    }
}
