import WidgetKit

struct MomsyWidgetEntry: TimelineEntry {
    let date: Date
    let feedingState: FeedingWidgetState
    let sleepState: SleepWidgetState

    static let placeholder = MomsyWidgetEntry(
        date: .now,
        feedingState: .running(
            effectiveStartDate: Date().addingTimeInterval(-754),
            side: "Левая"
        ),
        sleepState: .idle(lastDurationSeconds: 5400)
    )
}
