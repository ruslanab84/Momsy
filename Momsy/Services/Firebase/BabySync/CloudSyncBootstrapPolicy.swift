// Momsy/Services/Firebase/BabySync/CloudSyncBootstrapPolicy.swift
import Foundation

/// Pre-production bootstrap policy for local-first Firestore sync.
///
/// Momsy keeps log history in SwiftData. A device that has no checkpoint must therefore
/// start at a bounded checkpoint instead of downloading every remote document.
/// The only lookback is for baby sleep, so an already-running session remains visible
/// when the second parent opens the app.
enum CloudSyncBootstrapPolicy {
    /// Matches the app's maximum plausible open baby-sleep session.
    static let activeSleepLookback: TimeInterval = 24 * 60 * 60

    /// The application is not in production, so rollout migrations and legacy cleanup
    /// must not perform remote reads. Mark those one-time jobs complete before sync starts.
    private static let disabledLegacyJobFlags = [
        "babysync_perbaby_migration_v1_done",
        "firestore_quicklogs_cleanup_v1_done",
        "babysync_deletions_watermark_reset_v1_done",
    ]

    static func preparePreProductionDefaults(_ defaults: UserDefaults) {
        for key in disabledLegacyJobFlags {
            defaults.set(true, forKey: key)
        }
    }

    static func initialWatermark(for collection: String, now: Date) -> Date {
        collection == "sleepLogs"
            ? now.addingTimeInterval(-activeSleepLookback)
            : now
    }
}
