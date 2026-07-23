import Foundation
import SwiftData
import os

enum AppPersistence {
    typealias ContainerFactory = @MainActor (Schema, ModelConfiguration) throws -> ModelContainer

    // Informational only — recorded after a successful open so we can tell, in
    // diagnostics, which schema last wrote the store. It no longer gates a wipe;
    // migration is attempted in place to preserve user data.
    private static let schemaVersion = "v23"
    private static let schemaVersionKey = "AppPersistence.schemaVersion"

    private static let log = Logger(subsystem: "RuslanAbd.Momsy", category: "Persistence")
    private static let storeName = "default.store"
    private static let storeSuffixes = ["", "-shm", "-wal"]

    @MainActor
    static func makeContainer(
        defaults: UserDefaults = .standard,
        fileManager: FileManager = .default,
        storeURL: URL? = Self.storeURL,
        containerFactory: ContainerFactory = Self.makeModelContainer
    ) throws -> ModelContainer {
        let schema = makeSchema()
        let localConfig = ModelConfiguration(schema: schema)

        do {
            let container = try containerFactory(schema, localConfig)
            recordSuccess(defaults: defaults)
            return container
        } catch {
            let existingStoreError = error
            log.error("Failed to open existing SwiftData store: \(existingStoreError.localizedDescription, privacy: .public)")
            log.error("Store incompatible with current schema; backing up and recreating.")
            try backupStore(at: storeURL, fileManager: fileManager)
            deleteStore(at: storeURL, fileManager: fileManager)
            defaults.removeObject(forKey: schemaVersionKey)

            do {
                let container = try containerFactory(schema, localConfig)
                recordSuccess(defaults: defaults)
                return container
            } catch {
                log.fault("Fresh SwiftData store creation failed: \(error.localizedDescription, privacy: .public)")
                throw AppPersistenceError.freshStoreCreationFailed(
                    existingStoreError: existingStoreError,
                    freshStoreError: error
                )
            }
        }
    }

    @MainActor
    static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = makeSchema()
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try makeModelContainer(schema: schema, configuration: config)
    }

    private static func makeSchema() -> Schema {
        Schema([
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
            WeeklyInsightRecord.self,
            VitaminRecord.self,
        ])
    }

    @MainActor
    private static func makeModelContainer(
        schema: Schema,
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: configuration)
    }

    private static func recordSuccess(defaults: UserDefaults) {
        defaults.set(schemaVersion, forKey: schemaVersionKey)
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
    private static func backupStore(at store: URL?, fileManager: FileManager) throws {
        guard let store else { return }
        let backupBase = URL(fileURLWithPath: store.path + ".backup")
        for suffix in storeSuffixes {
            let src = URL(fileURLWithPath: store.path + suffix)
            let dst = URL(fileURLWithPath: backupBase.path + suffix)
            guard fileManager.fileExists(atPath: src.path) else { continue }
            do {
                if fileManager.fileExists(atPath: dst.path) {
                    try fileManager.removeItem(at: dst)
                }
                try fileManager.copyItem(at: src, to: dst)
            } catch {
                log.error("Store backup failed for \(src.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
                throw error
            }
        }
    }

    private static func deleteStore(at store: URL?, fileManager: FileManager) {
        guard let store else { return }
        for suffix in storeSuffixes {
            let url = URL(fileURLWithPath: store.path + suffix)
            try? fileManager.removeItem(at: url)
        }
    }
}

enum AppPersistenceError: LocalizedError {
    case freshStoreCreationFailed(existingStoreError: Error, freshStoreError: Error)

    var errorDescription: String? {
        switch self {
        case .freshStoreCreationFailed:
            "Momsy couldn't open its local data store."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .freshStoreCreationFailed:
            "Free up device storage if needed, then try again. Your previous store was backed up before Momsy attempted to create a fresh one."
        }
    }

    var technicalDetails: String {
        switch self {
        case let .freshStoreCreationFailed(existingStoreError, freshStoreError):
            return """
            Existing store: \(existingStoreError.localizedDescription)
            Fresh store: \(freshStoreError.localizedDescription)
            """
        }
    }
}
