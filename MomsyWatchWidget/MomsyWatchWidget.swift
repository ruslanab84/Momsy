import WidgetKit
import SwiftUI

// Watch face complications. All read the latest state mirrored from the iPhone via
// `WatchDataStore` (watch app group). The Watch app calls
// `WidgetCenter.shared.reloadAllTimelines()` whenever it receives fresh state.
//
// Target membership: this file + WatchMessage.swift + WatchDataStore.swift in the
// MomsyWatchWidget extension target.

struct WatchEntry: TimelineEntry {
    let date: Date
    let state: WatchState
}

struct WatchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchEntry {
        WatchEntry(date: Date(), state: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchEntry) -> Void) {
        completion(WatchEntry(date: Date(), state: WatchDataStore.shared.state))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchEntry>) -> Void) {
        let entry = WatchEntry(date: Date(), state: WatchDataStore.shared.state)
        // App pushes reloads on state change; no time-based refresh needed.
        completion(Timeline(entries: [entry], policy: .never))
    }
}

// MARK: - Time since last feeding

struct LastFeedingComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LastFeeding", provider: WatchProvider()) { entry in
            LastFeedingView(state: entry.state)
        }
        .configurationDisplayName(WatchStrings.lastFeeding)
        .description(WatchStrings.lastFeeding)
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}

private struct LastFeedingView: View {
    @Environment(\.widgetFamily) private var family
    let state: WatchState

    var body: some View {
        switch family {
        case .accessoryInline:
            Label(text, systemImage: "drop.fill")
        case .accessoryRectangular:
            HStack {
                Image(systemName: "drop.fill")
                VStack(alignment: .leading) {
                    Text(WatchStrings.lastFeeding).font(.caption2).foregroundStyle(.secondary)
                    Text(text).font(.headline)
                }
            }
        default:
            VStack(spacing: 1) {
                Image(systemName: "drop.fill").font(.caption)
                Text(text).font(.caption2).monospacedDigit()
            }
        }
    }

    private var text: String {
        guard let date = state.lastFeedingDate else { return WatchStrings.noData }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Active timer status

struct ActiveTimerComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ActiveTimer", provider: WatchProvider()) { entry in
            ActiveTimerView(state: entry.state)
        }
        .configurationDisplayName(WatchStrings.feeding + "/" + WatchStrings.sleep)
        .description(WatchStrings.feeding + "/" + WatchStrings.sleep)
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

private struct ActiveTimerView: View {
    let state: WatchState

    var body: some View {
        if let start = state.activeFeedingStart {
            timer(icon: "drop.fill", start: start)
        } else if let start = state.activeSleepStart {
            timer(icon: "moon.fill", start: start)
        } else {
            VStack(spacing: 1) {
                Image(systemName: "face.smiling").font(.caption)
                Text("Momsy").font(.caption2)
            }
        }
    }

    private func timer(icon: String, start: Date) -> some View {
        VStack(spacing: 1) {
            Image(systemName: icon).font(.caption)
            Text(start, style: .timer).font(.caption2).monospacedDigit()
        }
    }
}

// MARK: - Diapers today

struct DiaperCountComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DiaperCount", provider: WatchProvider()) { entry in
            DiaperCountView(count: entry.state.diaperCount)
        }
        .configurationDisplayName(WatchStrings.diapersToday)
        .description(WatchStrings.diapersToday)
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

private struct DiaperCountView: View {
    @Environment(\.widgetFamily) private var family
    let count: Int

    var body: some View {
        if family == .accessoryInline {
            Label("\(count)", systemImage: "leaf.fill")
        } else {
            VStack(spacing: 1) {
                Image(systemName: "leaf.fill").font(.caption)
                Text("\(count)").font(.headline).monospacedDigit()
            }
        }
    }
}

// MARK: - Launch shortcut

struct LaunchComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Launch", provider: WatchProvider()) { _ in
            Image(systemName: "face.smiling.inverse")
                .font(.title2)
        }
        .configurationDisplayName("Momsy")
        .description("Momsy")
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Bundle

@main
struct MomsyWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        LastFeedingComplication()
        ActiveTimerComplication()
        DiaperCountComplication()
        LaunchComplication()
    }
}
