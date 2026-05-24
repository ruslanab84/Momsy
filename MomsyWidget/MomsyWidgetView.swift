import SwiftUI
import WidgetKit

struct MomsyWidgetView: View {
    let entry: MomsyWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - System Small

private struct SmallWidgetView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch entry.feedingState {
            case .running(let start, let side):
                FeedingTimerView(effectiveStart: start, side: side, paused: false, pausedSecs: 0)
            case .paused(let secs, let side):
                FeedingTimerView(effectiveStart: .now, side: side, paused: true, pausedSecs: secs)
            case .idle:
                switch entry.sleepState {
                case .active(let start):
                    SleepTimerView(startDate: start)
                case .idle:
                    IdleSummaryView(entry: entry)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - System Medium

private struct MediumWidgetView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            FeedingColumn(state: entry.feedingState)
                .frame(maxWidth: .infinity)
            Divider().padding(.vertical, 8)
            SleepColumn(state: entry.sleepState)
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

private struct FeedingColumn: View {
    let state: FeedingWidgetState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Кормление", systemImage: "drop.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            switch state {
            case .running(let start, let side):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .minimumScaleFactor(0.7)
                Text(sideLabel(side)).font(.caption).foregroundStyle(.secondary)
            case .paused(let secs, let side):
                Text(formatSeconds(secs))
                    .font(.title2.monospacedDigit().weight(.semibold))
                HStack(spacing: 2) {
                    Image(systemName: "pause.fill").font(.caption2)
                    Text(sideLabel(side)).font(.caption)
                }
                .foregroundStyle(.secondary)
            case .idle(let lastDate):
                if let date = lastDate {
                    Text(date, style: .relative)
                        .font(.subheadline.monospacedDigit())
                    Text("назад").font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("—").font(.title2).foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

private struct SleepColumn: View {
    let state: SleepWidgetState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Сон", systemImage: "moon.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            switch state {
            case .active(let start):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .minimumScaleFactor(0.7)
                Text("активен").font(.caption).foregroundStyle(.green)
            case .idle(let dur):
                if let secs = dur {
                    Text(formatSeconds(secs))
                        .font(.subheadline.monospacedDigit())
                    Text("последний").font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("—").font(.title2).foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

// MARK: - Accessory Rectangular (Lock Screen)

private struct AccessoryRectangularView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            feedingRow
            sleepRow
        }
        .containerBackground(.clear, for: .widget)
    }

    @ViewBuilder private var feedingRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "drop.fill").frame(width: 12)
            switch entry.feedingState {
            case .running(let start, let side):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                Text(sideLabel(side))
            case .paused(let secs, let side):
                Text(formatSeconds(secs)).monospacedDigit()
                Image(systemName: "pause.fill").font(.caption2)
                Text(sideLabel(side))
            case .idle(let date):
                if let d = date {
                    Text(d, style: .relative).monospacedDigit()
                } else {
                    Text("—")
                }
            }
        }
        .font(.caption2)
    }

    @ViewBuilder private var sleepRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "moon.fill").frame(width: 12)
            switch entry.sleepState {
            case .active(let start):
                Text(timerInterval: start...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
            case .idle(let dur):
                if let secs = dur {
                    Text(formatSeconds(secs)).monospacedDigit()
                } else {
                    Text("—")
                }
            }
        }
        .font(.caption2)
    }
}

// MARK: - Subviews

private struct FeedingTimerView: View {
    let effectiveStart: Date
    let side: String
    let paused: Bool
    let pausedSecs: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Кормление", systemImage: "drop.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            if paused {
                Text(formatSeconds(pausedSecs))
                    .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                HStack(spacing: 4) {
                    Image(systemName: "pause.fill").font(.caption)
                    Text(sideLabel(side)).font(.caption)
                }
                .foregroundStyle(.secondary)
            } else {
                Text(timerInterval: effectiveStart...Date.distantFuture, countsDown: false)
                    .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                    .minimumScaleFactor(0.6)
                Text(sideLabel(side)).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private struct SleepTimerView: View {
    let startDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Сон", systemImage: "moon.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(timerInterval: startDate...Date.distantFuture, countsDown: false)
                .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                .minimumScaleFactor(0.6)
        }
    }
}

private struct IdleSummaryView: View {
    let entry: MomsyWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            feedingRow
            sleepRow
        }
    }

    @ViewBuilder private var feedingRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("Кормление", systemImage: "drop.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            if case .idle(let date) = entry.feedingState, let d = date {
                Text(d, style: .relative)
                    .font(.subheadline.monospacedDigit().weight(.medium))
                + Text(" назад").font(.caption).foregroundStyle(.secondary)
            } else {
                Text("—").foregroundStyle(.tertiary)
            }
        }
    }

    @ViewBuilder private var sleepRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("Сон", systemImage: "moon.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            if case .idle(let dur) = entry.sleepState, let secs = dur {
                Text(formatSeconds(secs))
                    .font(.subheadline.monospacedDigit().weight(.medium))
            } else {
                Text("—").foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Helpers

private func sideLabel(_ side: String) -> String {
    switch side {
    case "Левая":   return "←"
    case "Правая":  return "→"
    case "Бутылка": return "🍼"
    default:        return side
    }
}

private func formatSeconds(_ total: Int) -> String {
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
    return String(format: "%02d:%02d", m, s)
}
