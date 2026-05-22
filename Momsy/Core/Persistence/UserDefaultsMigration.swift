import Foundation
import SwiftData

enum UserDefaultsMigration {
    private static let flagKey = "swiftdata_migration_v1_done"

    static func runIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: flagKey) else { return }
        migrate(context: context)
        UserDefaults.standard.set(true, forKey: flagKey)
    }

    private static func migrate(context: ModelContext) {
        migrateSleep(context: context)
        migrateFeeding(context: context)
        migrateWalk(context: context)
        migrateBath(context: context)
        migrateBaby(context: context)
        migrateMeasurements(context: context)
        migrateTemperature(context: context)
        migrateLeaps(context: context)
        migrateChat(context: context)
        migrateDiary(context: context)
        try? context.save()
    }

    private static func migrateSleep(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_sleep_entries"),
              let entries = try? JSONDecoder().decode([SleepEntry].self, from: data)
        else { return }
        entries.forEach { context.insert(SleepRecord($0)) }
    }

    private static func migrateFeeding(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_feeding_entries"),
              let entries = try? JSONDecoder().decode([FeedingEntry].self, from: data)
        else { return }
        entries.forEach { context.insert(FeedingRecord($0)) }
    }

    private static func migrateWalk(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "walk_entries_v1"),
              let entries = try? JSONDecoder().decode([WalkEntry].self, from: data)
        else { return }
        entries.forEach { context.insert(WalkRecord($0)) }
    }

    private static func migrateBath(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "bath_entries_v1"),
              let entries = try? JSONDecoder().decode([BathEntry].self, from: data)
        else { return }
        entries.forEach { context.insert(BathRecord($0)) }
    }

    private static func migrateBaby(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_baby_profile"),
              let profile = try? JSONDecoder().decode(BabyProfile.self, from: data)
        else { return }
        context.insert(BabyRecord(profile))
    }

    private static func migrateMeasurements(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_measurements"),
              let entries = try? JSONDecoder().decode([MeasurementEntry].self, from: data)
        else { return }
        entries.forEach { context.insert(MeasurementRecord($0)) }
    }

    private static func migrateTemperature(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_temperature_log"),
              let entries = try? JSONDecoder().decode([TemperatureEntry].self, from: data)
        else { return }
        entries.forEach { context.insert(TemperatureRecord($0)) }
    }

    private static func migrateLeaps(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_leaps_progress"),
              let items = try? JSONDecoder().decode([LeapProgress].self, from: data)
        else { return }
        items.forEach { context.insert(LeapProgressRecord($0)) }
    }

    private static func migrateChat(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_chat_history"),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data)
        else { return }
        messages.forEach { context.insert(ChatMessageRecord($0)) }
    }

    private static func migrateDiary(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "local_diary_entries"),
              let items = try? JSONDecoder().decode([StoredDiaryItem].self, from: data)
        else { return }
        items.forEach { context.insert(DiaryItemRecord($0)) }
    }
}
