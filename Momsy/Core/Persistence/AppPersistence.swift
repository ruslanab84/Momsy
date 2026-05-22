import SwiftData

enum AppPersistence {
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
        ])
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }
}
