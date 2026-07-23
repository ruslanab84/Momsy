import WidgetKit

struct MomsyWidgetEntry: TimelineEntry {
    let date: Date
    let feedingState: FeedingWidgetState
    let sleepState: SleepWidgetState
    let babyName: String
    let babyBirthDate: Date?
    let diaperCount: Int
    let lastSleepEndDate: Date?
    let lastSleepStartDate: Date?

    static let placeholder = MomsyWidgetEntry(
        date: .now,
        feedingState: .running(
            effectiveStartDate: Date().addingTimeInterval(-754),
            side: "Левая"
        ),
        sleepState: .idle(lastDurationSeconds: 5400),
        babyName: "Лёва",
        babyBirthDate: Calendar.current.date(byAdding: .month, value: -4, to: .now),
        diaperCount: 5,
        lastSleepEndDate: Date().addingTimeInterval(-13200),
        lastSleepStartDate: Date().addingTimeInterval(-18600)
    )
}
