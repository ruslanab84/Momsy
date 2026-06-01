import Foundation
import SwiftData
import os

enum AppPersistence {
    // Informational only — recorded after a successful open so we can tell, in
    // diagnostics, which schema last wrote the store. It no longer gates a wipe;
    // migration is attempted in place to preserve user data.
    private static let schemaVersion = "v22"
    private static let schemaVersionKey = "AppPersistence.schemaVersion"

    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "Persistence")
    private static let storeName = "default.store"
    private static let storeSuffixes = ["", "-shm", "-wal"]

    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            SleepRecord.self,
            FeedingRecord.self,
            WalkRecord.self,
            BathRecord.self,
            BabyRecord.self,
            MeasurementRecord.self,
            TemperatureRecord.self,
            LeapProgressRecord.self,
            DiaryItemRecord.self,
            DoctorVisitRecord.self,
            VaccinationRecord.self,
            ComplementaryFoodRecord.self,
            DiaperRecord.self,
            MomMoodRecord.self,
            StoolRecord.self,
            WaterIntakeRecord.self,
            MomSleepRecord.self,
            PumpingRecord.self,
        ])

        // Local-only SwiftData store. Cross-device sync is handled entirely by
        // Firebase/Firestore (write-on-save + launch download + offline cache);
        // SwiftData is purely the on-device cache now that CloudKit is removed.
        let localConfig = ModelConfiguration(schema: schema)

        // 1. Open the existing store, letting SwiftData run an automatic
        //    lightweight migration in place. This preserves all local data.
        if let container = try? ModelContainer(for: schema, configurations: localConfig) {
            recordSuccess()
            return container
        }

        // 2. Last resort: the on-disk store is genuinely incompatible with the
        //    current schema and SwiftData cannot migrate it. Move it aside (do not
        //    destroy it) so it stays recoverable, then create a fresh store.
        log.error("Store incompatible with current schema; backing up and recreating.")
        backupStore()
        deleteStore()
        UserDefaults.standard.removeObject(forKey: schemaVersionKey)

        if let container = try? ModelContainer(for: schema, configurations: localConfig) {
            recordSuccess()
            return container
        }

        fatalError("SwiftData container failed even with a fresh store.")
    }

    private static func recordSuccess() {
        UserDefaults.standard.set(schemaVersion, forKey: schemaVersionKey)
    }

    private static var storeURL: URL? {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(storeName)
    }

    /// Copies the current store aside before a destructive recreate, so a failed
    /// migration is recoverable rather than permanent data loss. Keeps only the
    /// most recent backup to avoid unbounded disk growth.
    private static func backupStore() {
        guard let store = storeURL else { return }
        let backupBase = URL(fileURLWithPath: store.path + ".backup")
        for suffix in storeSuffixes {
            let src = URL(fileURLWithPath: store.path + suffix)
            let dst = URL(fileURLWithPath: backupBase.path + suffix)
            guard FileManager.default.fileExists(atPath: src.path) else { continue }
            try? FileManager.default.removeItem(at: dst)
            do {
                try FileManager.default.copyItem(at: src, to: dst)
            } catch {
                log.error("Store backup failed for \(src.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private static func deleteStore() {
        guard let store = storeURL else { return }
        for suffix in storeSuffixes {
            let url = URL(fileURLWithPath: store.path + suffix)
            try? FileManager.default.removeItem(at: url)
        }
    }
}
