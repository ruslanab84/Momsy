import Foundation
import SwiftData

enum AppPersistence {
    // Bump this string whenever you change the SwiftData schema.
    private static let schemaVersion = "v17"
    private static let schemaVersionKey = "AppPersistence.schemaVersion"

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
            ChatMessageRecord.self,
            DiaryItemRecord.self,
            DoctorVisitRecord.self,
            VaccinationRecord.self,
            ComplementaryFoodRecord.self,
            DiaperRecord.self,
            MomMoodRecord.self,
            StoolRecord.self,
            MomSleepRecord.self,
        ])

        // If schema version changed since last run, wipe the old store
        // before SwiftData tries (and hangs) on incompatible migration.
        let stored = UserDefaults.standard.string(forKey: schemaVersionKey)
        if stored != schemaVersion {
            deleteStore()
        }

        do {
            let container = try ModelContainer(for: schema)
            UserDefaults.standard.set(schemaVersion, forKey: schemaVersionKey)
            return container
        } catch {
            // Fallback: delete and retry once.
            deleteStore()
            UserDefaults.standard.removeObject(forKey: schemaVersionKey)
            do {
                let container = try ModelContainer(for: schema)
                UserDefaults.standard.set(schemaVersion, forKey: schemaVersionKey)
                return container
            } catch {
                fatalError("SwiftData container failed after store reset: \(error)")
            }
        }
    }

    private static func deleteStore() {
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let store = dir.appendingPathComponent("default.store")
        for suffix in ["", "-shm", "-wal"] {
            let url = suffix.isEmpty ? store : URL(fileURLWithPath: store.path + suffix)
            try? FileManager.default.removeItem(at: url)
        }
    }
}
