import WidgetKit
import SwiftUI

@main
struct MomsyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MomsyFeedSleepWidget()
    }
}

struct MomsyFeedSleepWidget: Widget {
    let kind = WidgetDataStore.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomsyWidgetProvider()) { entry in
            MomsyWidgetView(entry: entry)
        }
        .configurationDisplayName("Momsy")
        .description("Таймер кормления и сна")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
