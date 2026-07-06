import SwiftUI
import WidgetKit

private let bbCoral   = Color(red: 0.941, green: 0.541, blue: 0.431)
private let bbLilac   = Color(red: 0.624, green: 0.510, blue: 0.847)
private let bbInk     = Color(red: 0.239, green: 0.165, blue: 0.125)
private let bbInkSoft = Color(red: 0.420, green: 0.329, blue: 0.275)
private let bbCream   = Color(red: 1.0,   green: 0.965, blue: 0.925)

struct MomsySummaryWidgetView: View {
    let entry: MomsyWidgetEntry

    private var ageString: String {
        guard let birth = entry.babyBirthDate else { return "" }
        let months = Calendar.current.dateComponents([.month], from: birth, to: .now).month ?? 0
        return WidgetL10n.current.ageMonths(months)
    }

    private var hasLeap: Bool {
        guard let birth = entry.babyBirthDate else { return false }
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: birth, to: .now).weekOfYear ?? 0
        return DevelopmentLeapSchedule.weeks.contains(where: { abs($0 - weeks) <= DevelopmentLeapSchedule.lookaheadWeeks })
    }

    private var lastSleepDuration: String? {
        if case .idle(let secs) = entry.sleepState, let s = secs {
            return WidgetL10n.current.duration(seconds: s)
        }
        if case .active(let start) = entry.sleepState {
            let secs = Int(Date().timeIntervalSince(start))
            return WidgetL10n.current.sleepingDuration(seconds: secs)
        }
        return nil
    }

    var body: some View {
        content
            .widgetURL(URL(string: "momsy://today"))
    }

    @ViewBuilder private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 4) {
                    Text(entry.babyName.isEmpty ? WidgetL10n.current.baby : entry.babyName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(bbInk)
                    if !ageString.isEmpty {
                        Text("·")
                            .foregroundStyle(bbInkSoft)
                        Text(ageString)
                            .font(.subheadline)
                            .foregroundStyle(bbInkSoft)
                    }
                }
                Spacer()
                Text(WidgetL10n.current.today)
                    .font(.caption2)
                    .foregroundStyle(bbInkSoft)
            }

            Spacer()

            // Data grid
            VStack(spacing: 6) {
                HStack {
                    // Feeding
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(bbCoral)
                            .font(.caption)
                        switch entry.feedingState {
                        case .running(let start, _):
                            Text(timerInterval: start...Date.distantFuture, countsDown: false)
                                .font(.subheadline.monospacedDigit().weight(.medium))
                                .minimumScaleFactor(0.7)
                        case .idle(let date):
                            if let d = date {
                                Text(d, style: .relative)
                                    .font(.subheadline.monospacedDigit())
                                    .minimumScaleFactor(0.7)
                            } else {
                                Text("—").font(.subheadline).foregroundStyle(.tertiary)
                            }
                        case .paused(let secs, _):
                            Text(formatSecs(secs))
                                .font(.subheadline.monospacedDigit())
                        }
                    }
                    Spacer()
                    // Diapers
                    HStack(spacing: 4) {
                        Text("💧")
                            .font(.caption)
                        Text("\(entry.diaperCount)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(bbInk)
                    }
                }

                HStack {
                    // Sleep
                    HStack(spacing: 4) {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(bbLilac)
                            .font(.caption)
                        if let dur = lastSleepDuration {
                            Text(dur)
                                .font(.subheadline.monospacedDigit())
                                .minimumScaleFactor(0.7)
                        } else {
                            Text("—").font(.subheadline).foregroundStyle(.tertiary)
                        }
                    }
                    Spacer()
                    // Leap indicator
                    if hasLeap {
                        HStack(spacing: 4) {
                            Text("⚡")
                                .font(.caption)
                            Text(WidgetL10n.current.leap)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(bbInk)
                        }
                    }
                }
            }
        }
        .padding(14)
        .colorScheme(.light)
        .containerBackground(bbCream, for: .widget)
    }
}

private func formatSecs(_ total: Int) -> String {
    let h = total / 3600
    let m = (total % 3600) / 60
    let s = total % 60
    if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
    return String(format: "%02d:%02d", m, s)
}
