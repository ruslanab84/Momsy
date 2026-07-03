import SwiftUI
import WidgetKit

private let bbLilac   = Color(red: 0.624, green: 0.510, blue: 0.847)
private let bbInk     = Color(red: 0.239, green: 0.165, blue: 0.125)
private let bbCream   = Color(red: 1.0,   green: 0.965, blue: 0.925)

struct MomsySleepWidgetView: View {
    let entry: MomsyWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .widgetURL(URL(string: "momsy://today"))
    }

    @ViewBuilder private var content: some View {
        switch family {
        case .systemSmall:
            SleepSmallView(entry: entry)
        case .systemMedium:
            SleepMediumView(entry: entry)
        case .accessoryRectangular:
            SleepAccessoryRectView(entry: entry)
        default:
            SleepSmallView(entry: entry)
        }
    }
}

// MARK: - System Small

private struct SleepSmallView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(WidgetL10n.current.sleep, systemImage: "moon.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(bbLilac)
            switch entry.sleepState {
            case .active(let start):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                    .minimumScaleFactor(0.6)
                Text(WidgetL10n.current.sleeping).font(.caption).foregroundStyle(.secondary)
            case .idle:
                if let end = entry.lastSleepEndDate {
                    Text(end, style: .relative)
                        .font(.system(.title2, design: .rounded, weight: .semibold).monospacedDigit())
                        .minimumScaleFactor(0.6)
                    Text(WidgetL10n.current.ago).font(.caption).foregroundStyle(.secondary)
                } else if let name = entry.babyName.nilIfEmpty {
                    Text(WidgetL10n.current.openMomsyFor(name))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(WidgetL10n.current.noData)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .colorScheme(.light)
        .containerBackground(bbCream, for: .widget)
    }
}

// MARK: - System Medium

private struct SleepMediumView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            SleepStatusColumn(entry: entry)
                .frame(maxWidth: .infinity)
            Divider().padding(.vertical, 8)
            SleepLastColumn(entry: entry)
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .colorScheme(.light)
        .containerBackground(bbCream, for: .widget)
    }
}

private struct SleepStatusColumn: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(WidgetL10n.current.sleep, systemImage: "moon.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(bbLilac)
            switch entry.sleepState {
            case .active(let start):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .minimumScaleFactor(0.7)
                Text(WidgetL10n.current.sleepingNow).font(.caption).foregroundStyle(.green)
            case .idle:
                if let end = entry.lastSleepEndDate {
                    Text(end, style: .relative)
                        .font(.subheadline.monospacedDigit())
                    Text(WidgetL10n.current.wokeUp).font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("—").font(.title2).foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

private struct SleepLastColumn: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(WidgetL10n.current.last, systemImage: "clock.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(bbLilac.opacity(0.7))
            if case .idle(let dur) = entry.sleepState, let secs = dur {
                Text(formatDuration(secs))
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                Text(WidgetL10n.current.duration).font(.caption2).foregroundStyle(.secondary)
            } else if case .active = entry.sleepState {
                Text(WidgetL10n.current.inProgress).font(.caption).foregroundStyle(.secondary)
            } else {
                Text("—").font(.title2).foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

// MARK: - Accessory Rectangular (Lock Screen)

private struct SleepAccessoryRectView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.fill").frame(width: 12)
            switch entry.sleepState {
            case .active(let start):
                Text(WidgetL10n.current.sleeping)
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
            case .idle:
                if let end = entry.lastSleepEndDate {
                    Text(WidgetL10n.current.wokeUp)
                    Text(end, style: .relative).monospacedDigit()
                } else {
                    Text(WidgetL10n.current.noData)
                }
            }
        }
        .font(.caption2)
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Helpers

private func formatDuration(_ total: Int) -> String {
    WidgetL10n.current.duration(seconds: total)
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
