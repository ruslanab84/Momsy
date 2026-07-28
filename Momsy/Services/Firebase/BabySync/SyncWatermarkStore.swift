// Momsy/Services/Firebase/BabySync/SyncWatermarkStore.swift
import Foundation

/// Per-`(family, baby, collection)` high-water mark for incremental cloud sync.
/// Stores the greatest `updatedAt` (server time) merged for a collection so the next pull
/// fetches only newer documents. Backed by `UserDefaults`; injectable for tests.
final class SyncWatermarkStore {
    private let defaults: UserDefaults
    private let now: () -> Date

    /// Serializes the read-modify-write of the shared per-`(family, baby)` bucket. The downloader
    /// fires all collections' watermark updates concurrently into one `UserDefaults` dictionary,
    /// so an unguarded `set` would lose updates and silently re-bootstrap a collection.
    private let lock = NSLock()

    init(
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { Date() }
    ) {
        self.defaults = defaults
        self.now = now
        CloudSyncBootstrapPolicy.preparePreProductionDefaults(defaults)
    }

    private func bucketKey(_ family: String, _ baby: String) -> String {
        "babysync_watermarks_v1_\(family)_\(baby)"
    }

    private func bucket(_ family: String, _ baby: String) -> [String: Double] {
        defaults.dictionary(forKey: bucketKey(family, baby)) as? [String: Double] ?? [:]
    }

    /// Returns the stored watermark. On a clean scope it atomically creates a bounded
    /// bootstrap checkpoint instead of returning `nil`; this keeps the downloader on its
    /// delta-query path and prevents an automatic full-history Firestore read.
    ///
    /// `sleepLogs` receives a 24-hour lookback so an open sleep started by the other parent
    /// before this device attached is still recovered. Every other log starts at `now`.
    func watermark(family: String, baby: String, collection: String) -> Date? {
        guard !family.isEmpty, !baby.isEmpty else { return nil }
        lock.lock(); defer { lock.unlock() }

        var dict = bucket(family, baby)
        if let seconds = dict[collection] {
            return Date(timeIntervalSince1970: seconds)
        }

        let initial = CloudSyncBootstrapPolicy.initialWatermark(for: collection, now: now())
        dict[collection] = initial.timeIntervalSince1970
        defaults.set(dict, forKey: bucketKey(family, baby))
        return initial
    }

    /// Sets the watermark unconditionally. No-op when the path isn't ready.
    func set(family: String, baby: String, collection: String, to date: Date) {
        guard !family.isEmpty, !baby.isEmpty else { return }
        lock.lock(); defer { lock.unlock() }
        var dict = bucket(family, baby)
        dict[collection] = date.timeIntervalSince1970
        defaults.set(dict, forKey: bucketKey(family, baby))
    }

    /// Clears every watermark for a `(family, baby)`. The next access creates fresh
    /// bounded checkpoints; it never falls back to downloading the complete cloud history.
    func reset(family: String, baby: String) {
        guard !family.isEmpty, !baby.isEmpty else { return }
        lock.lock(); defer { lock.unlock() }
        defaults.removeObject(forKey: bucketKey(family, baby))
    }
}
