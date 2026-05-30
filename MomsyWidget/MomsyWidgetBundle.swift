import WidgetKit
import SwiftUI

@main
struct MomsyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MomsyFeedingWidget()
        MomsySleepWidget()
        MomsySummaryWidget()
        FeedingLiveActivity()
        SleepLiveActivity()
        WalkLiveActivity()
        BathLiveActivity()
        PumpingLiveActivity()
    }
}

struct MomsyFeedingWidget: Widget {
    let kind = "MomsyFeedingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomsyWidgetProvider()) { entry in
            MomsyFeedingWidgetView(entry: entry)
        }
        .configurationDisplayName("Кормление")
        .description("Таймер кормления")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct MomsySleepWidget: Widget {
    let kind = "MomsySleepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomsyWidgetProvider()) { entry in
            MomsySleepWidgetView(entry: entry)
        }
        .configurationDisplayName("Сон")
        .description("Трекер сна")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct MomsySummaryWidget: Widget {
    let kind = "MomsySummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomsyWidgetProvider()) { entry in
            MomsySummaryWidgetView(entry: entry)
        }
        .configurationDisplayName("Сводка дня")
        .description("Кормление, сон и подгузники")
        .supportedFamilies([.systemMedium])
    }
}
