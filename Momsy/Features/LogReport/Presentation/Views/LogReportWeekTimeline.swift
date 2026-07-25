import SwiftUI

struct LogReportWeekTimeline: View {
    @ObservedObject var vm: LogReportViewModel
    @EnvironmentObject private var units: UnitSystemManager

    private let hourHeight: CGFloat = 24
    private var timelineHeight: CGFloat { hourHeight * 24 }
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 8) {
            weekHeader
            HStack(alignment: .top, spacing: 0) {
                hourAxis
                ForEach(vm.weekDays, id: \.self) { day in
                    dayColumn(day)
                }
            }
            .frame(height: timelineHeight)
        }
        .bbCard(pad: 14)
    }

    // MARK: - Header

    private var weekHeader: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: units.isImperial ? 48 : 34)
            ForEach(vm.weekDays, id: \.self) { day in
                let selected = calendar.isDate(day, inSameDayAs: vm.selectedDate)
                VStack(spacing: 2) {
                    Text(weekdayLabel(day))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                    Text("\(calendar.component(.day, from: day))")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(selected ? .white : .bbInk)
                        .frame(width: 26, height: 26)
                        .background(selected ? Color.bbCoralDeep : .clear)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { vm.selectedDate = day }
            }
        }
    }

    // MARK: - Axis & columns

    private var hourAxis: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(stride(from: 0, through: 22, by: 2)), id: \.self) { hour in
                Text(hourDate(hour), format: units.current.timeFormatStyle(includingMinutes: false))
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.bbInkMute)
                    .offset(y: CGFloat(hour) * hourHeight - 5)
            }
        }
        .frame(width: units.isImperial ? 48 : 34, height: timelineHeight, alignment: .topLeading)
    }

    private func dayColumn(_ day: Date) -> some View {
        let selected = calendar.isDate(day, inSameDayAs: vm.selectedDate)
        return ZStack(alignment: .top) {
            gridLines
            if selected {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.bbCoral.opacity(0.08))
            }
            GeometryReader { geo in
                ForEach(vm.timelineSegments(on: day)) { segment in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(segment.kind.defaultTone)
                        .frame(
                            width: max(4, geo.size.width - 6),
                            height: segment.isInstant
                                ? 3
                                : max(4, CGFloat(segment.endMinute - segment.startMinute) / 60 * hourHeight)
                        )
                        .offset(x: 3, y: CGFloat(segment.startMinute) / 60 * hourHeight)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { vm.selectedDate = day }
    }

    private var gridLines: some View {
        ZStack(alignment: .top) {
            ForEach(0..<13, id: \.self) { step in
                Rectangle()
                    .fill(Color.bbInkMute.opacity(0.12))
                    .frame(height: 0.5)
                    .offset(y: CGFloat(step) * hourHeight * 2)
            }
        }
    }

    private func weekdayLabel(_ day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day)
    }

    private func hourDate(_ hour: Int) -> Date {
        calendar.date(bySettingHour: hour, minute: 0, second: 0, of: vm.range.from)
            ?? vm.range.from
    }
}
