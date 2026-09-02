import WidgetKit
import SwiftUI

@main
struct MomsyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MomsyFeedingWidget()
        MomsySleepWidget()
        MomsySummaryWidget()
        MomsyStandByWidget()
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
        .configurationDisplayName(WidgetL10n.current.feeding)
        .description(WidgetL10n.current.widgetFeedingDescription)
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct MomsySleepWidget: Widget {
    let kind = "MomsySleepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomsyWidgetProvider()) { entry in
            MomsySleepWidgetView(entry: entry)
        }
        .configurationDisplayName(WidgetL10n.current.sleep)
        .description(WidgetL10n.current.widgetSleepDescription)
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct MomsySummaryWidget: Widget {
    let kind = "MomsySummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomsyWidgetProvider()) { entry in
            MomsySummaryWidgetView(entry: entry)
        }
        .configurationDisplayName(WidgetL10n.current.widgetSummaryName)
        .description(WidgetL10n.current.widgetSummaryDescription)
        .supportedFamilies([.systemMedium])
    }
}

struct MomsyStandByWidget: Widget {
    let kind = "MomsyStandByWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomsyWidgetProvider()) { entry in
            MomsyStandByWidgetView(entry: entry)
        }
        .configurationDisplayName(WidgetL10n.current.widgetStandByName)
        .description(WidgetL10n.current.widgetStandByDescription)
        .supportedFamilies([.systemSmall])
    }
}
