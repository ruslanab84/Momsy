import SwiftUI
import WidgetKit

private let bbLilac   = Color(red: 0.624, green: 0.510, blue: 0.847)
private let bbInk     = Color(red: 0.239, green: 0.165, blue: 0.125)
private let bbCream   = Color(red: 1.0,   green: 0.965, blue: 0.925)
private let bbQuickCoral = Color(red: 1.0,   green: 0.549, blue: 0.447)
private let bbQuickLilac = Color(red: 0.753, green: 0.643, blue: 0.973)
private let bbQuickMint  = Color(red: 0.471, green: 0.831, blue: 0.722)
private let bbQuickSky   = Color(red: 0.533, green: 0.800, blue: 0.925)
private let bbQuickSkyDeep = Color(red: 0.227, green: 0.557, blue: 0.784)

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
                    Text(end, style: .time)
                        .font(.system(.title2, design: .rounded, weight: .semibold).monospacedDigit())
                        .minimumScaleFactor(0.6)
                    Text(WidgetL10n.current.wokeUp).font(.caption).foregroundStyle(.secondary)
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
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                SleepStatusColumn(entry: entry)
                    .frame(maxWidth: .infinity)
                Divider().padding(.vertical, 8)
                SleepLastColumn(entry: entry)
                    .frame(maxWidth: .infinity)
            }

            HStack {
                WidgetActivityIcon(color: bbQuickLilac) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 20, weight: .semibold))
                }
                Spacer()
                WidgetActivityIcon(color: bbQuickCoral) {
                    WidgetBottleIcon()
                }
                Spacer()
                WidgetActivityIcon(color: bbQuickSky) {
                    WidgetDiaperIcon()
                }
                Spacer()
                WidgetActivityIcon(color: bbQuickMint) {
                    Image(systemName: "stroller")
                        .font(.system(size: 20, weight: .semibold))
                }
                Spacer()
                WidgetActivityIcon(color: bbQuickSky) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 20, weight: .semibold))
                }
            }
            .padding(.horizontal, 4)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .colorScheme(.light)
        .containerBackground(bbCream, for: .widget)
    }
}

private struct WidgetActivityIcon<Content: View>: View {
    let color: Color
    let content: Content

    init(color: Color, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }

    var body: some View {
        content
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .frame(width: 40, height: 40)
            .background(color, in: Circle())
    }
}

private struct WidgetBottleIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(.white)
                .frame(width: 12, height: 18)
                .offset(y: 2)
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(red: 1.0, green: 0.945, blue: 0.870))
                .frame(width: 9, height: 7)
                .offset(y: 6)
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(Color(red: 0.910, green: 0.345, blue: 0.165))
                .frame(width: 9, height: 4)
                .offset(y: -8)
        }
    }
}

private struct WidgetDiaperIcon: View {
    var body: some View {
        ZStack {
            WidgetDiaperShape()
                .fill(.white.opacity(0.92))
                .frame(width: 22, height: 22)
            RoundedRectangle(cornerRadius: 1.5)
                .fill(bbQuickSkyDeep)
                .frame(width: 7, height: 4)
                .offset(x: -11, y: -7)
            RoundedRectangle(cornerRadius: 1.5)
                .fill(bbQuickSkyDeep)
                .frame(width: 7, height: 4)
                .offset(x: 11, y: -7)
        }
    }
}

private struct WidgetDiaperShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.08, y: 0))
        path.addLine(to: CGPoint(x: width * 0.92, y: 0))
        path.addCurve(
            to: CGPoint(x: width * 0.72, y: height * 0.5),
            control1: CGPoint(x: width, y: height * 0.08),
            control2: CGPoint(x: width * 0.72, y: height * 0.38)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.92, y: height),
            control1: CGPoint(x: width * 0.72, y: height * 0.62),
            control2: CGPoint(x: width, y: height * 0.92)
        )
        path.addLine(to: CGPoint(x: width * 0.08, y: height))
        path.addCurve(
            to: CGPoint(x: width * 0.28, y: height * 0.5),
            control1: CGPoint(x: 0, y: height * 0.92),
            control2: CGPoint(x: width * 0.28, y: height * 0.62)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.08, y: 0),
            control1: CGPoint(x: width * 0.28, y: height * 0.38),
            control2: CGPoint(x: 0, y: height * 0.08)
        )
        path.closeSubpath()
        return path
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
                    Text(end, style: .time)
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
                    Text(end, style: .time).monospacedDigit()
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
