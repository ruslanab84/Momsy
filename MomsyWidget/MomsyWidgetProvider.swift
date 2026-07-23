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
        // 60s refresh when feeding/sleep is active; 15min otherwise
        let isActive: Bool
        switch entry.feedingState {
        case .running: isActive = true
        default:
            if case .active = entry.sleepState { isActive = true } else { isActive = false }
        }
        let interval: Int = isActive ? 1 : 15
        let next = Calendar.current.date(byAdding: .minute, value: interval, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func liveEntry() -> MomsyWidgetEntry {
        MomsyWidgetEntry(
            date: .now,
            feedingState: WidgetDataStore.shared.feedingState,
            sleepState: WidgetDataStore.shared.sleepState,
            babyName: WidgetDataStore.shared.babyName,
            babyBirthDate: WidgetDataStore.shared.babyBirthDate,
            diaperCount: WidgetDataStore.shared.diaperCount,
            lastSleepEndDate: WidgetDataStore.shared.lastSleepEndDate,
            lastSleepStartDate: WidgetDataStore.shared.lastSleepStartDate
        )
    }
}
