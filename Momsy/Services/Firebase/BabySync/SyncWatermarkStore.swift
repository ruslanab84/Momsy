// Momsy/Services/Firebase/BabySync/SyncWatermarkStore.swift
import Foundation

/// Per-`(family, baby, collection)` high-water mark for incremental cloud sync.
/// Stores the greatest `updatedAt` (server time) merged for a collection so the next pull
/// fetches only newer documents. Backed by `UserDefaults`; injectable for tests.
final class SyncWatermarkStore {
    private let defaults: UserDefaults
    /// Serializes the read-modify-write of the shared per-`(family, baby)` bucket. The downloader
    /// fires all 17 collections' watermark updates concurrently into one `UserDefaults` dictionary,
    /// so an unguarded `set` would lose updates and silently drop collections back to full pulls.
    private let lock = NSLock()
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private func bucketKey(_ family: String, _ baby: String) -> String {
        "babysync_watermarks_v1_\(family)_\(baby)"
    }

    private func bucket(_ family: String, _ baby: String) -> [String: Double] {
        defaults.dictionary(forKey: bucketKey(family, baby)) as? [String: Double] ?? [:]
    }

    /// The stored watermark for a collection, or `nil` if this collection has never synced under
    /// this `(family, baby)` (→ caller does a one-time full pull).
    func watermark(family: String, baby: String, collection: String) -> Date? {
        guard !family.isEmpty, !baby.isEmpty else { return nil }
        lock.lock(); defer { lock.unlock() }
        guard let seconds = bucket(family, baby)[collection] else { return nil }
        return Date(timeIntervalSince1970: seconds)
    }

    /// Sets the watermark unconditionally. No-op when the path isn't ready.
    func set(family: String, baby: String, collection: String, to date: Date) {
        guard !family.isEmpty, !baby.isEmpty else { return }
        lock.lock(); defer { lock.unlock() }
        var dict = bucket(family, baby)
        dict[collection] = date.timeIntervalSince1970
        defaults.set(dict, forKey: bucketKey(family, baby))
    }

    /// Clears every watermark for a `(family, baby)` — call on full cloud erasure so a re-add
    /// re-seeds from a clean full pull.
    func reset(family: String, baby: String) {
        guard !family.isEmpty, !baby.isEmpty else { return }
        lock.lock(); defer { lock.unlock() }
        defaults.removeObject(forKey: bucketKey(family, baby))
    }
}
