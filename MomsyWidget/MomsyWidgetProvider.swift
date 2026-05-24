import WidgetKit

struct MomsyWidgetProvider: TimelineProvider {
    typealias Entry = MomsyWidgetEntry

    func placeholder(in context: Context) -> MomsyWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MomsyWidgetEntry) -> Void) {
        completion(context.isPreview ? .placeholder : liveEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MomsyWidgetEntry>) -> Void) {
        let entry = liveEntry()
        // Refresh every 15 min as a safety net; primary updates come from WidgetCenter.reloadTimelines
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func liveEntry() -> MomsyWidgetEntry {
        MomsyWidgetEntry(
            date: .now,
            feedingState: WidgetDataStore.shared.feedingState,
            sleepState: WidgetDataStore.shared.sleepState
        )
    }
}
