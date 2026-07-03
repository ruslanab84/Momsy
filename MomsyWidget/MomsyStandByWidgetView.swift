import SwiftUI
import WidgetKit

private let bbCoral = Color(red: 0.965, green: 0.604, blue: 0.498)
private let bbLilac = Color(red: 0.737, green: 0.643, blue: 0.937)
private let bbInk   = Color(red: 0.96,  green: 0.94,  blue: 0.98)
private let bbInkSoft = Color(red: 0.74, green: 0.71, blue: 0.82)
private let bbNight = Color(red: 0.10, green: 0.08, blue: 0.16)

struct MomsyStandByWidgetView: View {
    let entry: MomsyWidgetEntry
    @Environment(\.isLuminanceReduced) private var dimmed

    private var ageString: String {
        guard let birth = entry.babyBirthDate else { return "" }
        let months = Calendar.current.dateComponents([.month], from: birth, to: .now).month ?? 0
        return WidgetL10n.current.ageMonths(months)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            feedingRow
            sleepRow
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .colorScheme(.dark)
        .opacity(dimmed ? 0.7 : 1)
        .containerBackground(bbNight, for: .widget)
        .widgetURL(URL(string: "momsy://today"))
    }

    @ViewBuilder private var header: some View {
        HStack(spacing: 4) {
            Text(entry.babyName.isEmpty ? WidgetL10n.current.baby : entry.babyName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(bbInk)
            if !ageString.isEmpty {
                Text("·").foregroundStyle(bbInkSoft)
                Text(ageString).font(.subheadline).foregroundStyle(bbInkSoft)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    @ViewBuilder private var feedingRow: some View {
        StandByRow(icon: "drop.fill", accent: bbCoral) {
            switch entry.feedingState {
            case .running(let start, let side):
                liveTimer(from: start, caption: sideLabel(side))
            case .paused(let secs, let side):
                staticValue(formatSeconds(secs), caption: "\u{23F8} \(sideLabel(side))")
            case .idle(let lastDate):
                if let date = lastDate {
                    relativeValue(date)
                } else {
                    emptyValue
                }
            }
        }
    }

    @ViewBuilder private var sleepRow: some View {
        StandByRow(icon: "moon.fill", accent: bbLilac) {
            switch entry.sleepState {
            case .active(let start):
                liveTimer(from: start, caption: WidgetL10n.current.sleeping)
            case .idle(let dur):
                if let end = entry.lastSleepEndDate {
                    relativeValue(end)
                } else if let secs = dur {
                    staticValue(formatSeconds(secs), caption: WidgetL10n.current.last)
                } else {
                    emptyValue
                }
            }
        }
    }

    // MARK: - Value builders

    @ViewBuilder private func liveTimer(from start: Date, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(timerInterval: start...Date.distantFuture, countsDown: false)
                .font(.system(.title2, design: .rounded, weight: dimmed ? .semibold : .bold).monospacedDigit())
                .foregroundStyle(bbInk)
                .minimumScaleFactor(0.6)
            Text(caption).font(.caption2).foregroundStyle(bbInkSoft)
        }
    }

    @ViewBuilder private func relativeValue(_ date: Date) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(date, style: .relative)
                .font(.system(.title3, design: .rounded, weight: .semibold).monospacedDigit())
                .foregroundStyle(bbInk)
                .minimumScaleFactor(0.6)
            Text(WidgetL10n.current.ago).font(.caption2).foregroundStyle(bbInkSoft)
        }
    }

    @ViewBuilder private func staticValue(_ value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .semibold).monospacedDigit())
                .foregroundStyle(bbInk)
                .minimumScaleFactor(0.6)
            Text(caption).font(.caption2).foregroundStyle(bbInkSoft)
        }
    }

    @ViewBuilder private var emptyValue: some View {
        Text("—").font(.title3).foregroundStyle(bbInkSoft)
    }
}

// MARK: - Row scaffold

private struct StandByRow<Value: View>: View {
    let icon: String
    let accent: Color
    @ViewBuilder let value: () -> Value

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(accent)
                .frame(width: 24)
            value()
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Helpers

private func sideLabel(_ side: String) -> String {
    switch side {
    case "left", "Левая":   return "←"
    case "right", "Правая":  return "→"
    case "bottle", "Бутылка": return "🍼"
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
