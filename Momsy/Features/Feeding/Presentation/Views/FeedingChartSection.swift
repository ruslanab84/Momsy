import SwiftUI

struct FeedingChartSection: View {
    let days: [FeedingDayPoint]
    @Binding var selectedPeriod: Int
    let lang: String

    @EnvironmentObject private var loc: LocalizationManager

    private let chartMax: Double = 15
    private let chartHeight: CGFloat = 150
    private let labelHeight: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            periodPicker
            if days.isEmpty || days.allSatisfy({ $0.sessionCount == 0 }) {
                emptyState
            } else {
                chart
                statsRow
            }
        }
        .padding(14)
        .background(FeedingPosterPalette.paper.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.68), lineWidth: 1)
        )
    }

    // MARK: - Header

    private var headerRow: some View {
        Text(loc.strings.feedingChartTitle.uppercased())
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundStyle(FeedingPosterPalette.inkMute)
            .kerning(0.5)
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 8) {
            chip(title: loc.strings.feedingPeriodWeek, index: 0)
            chip(title: loc.strings.feedingPeriodMonth, index: 1)
        }
    }

    private func chip(title: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedPeriod = index
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(selectedPeriod == index ? Color.white : FeedingPosterPalette.inkSoft)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedPeriod == index ? Color.bbCoralDeep : Color.bbCoral.opacity(0.15))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Chart

    private var chart: some View {
        GeometryReader { geo in
            let count = max(1, days.count)
            let sp: CGFloat = count > 14 ? 2 : 4
            let bw = max(6, (geo.size.width - sp * CGFloat(count - 1)) / CGFloat(count))
            let barAreaH = chartHeight - labelHeight

            ZStack(alignment: .bottomLeading) {
                // Gridlines at 3 and 6 sessions
                Canvas { ctx, size in
                    let areaH = size.height - labelHeight
                    for gridCount in [3.0, 6.0] {
                        let y = (1 - gridCount / chartMax) * areaH
                        var p = Path()
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                        ctx.stroke(p, with: .color(.bbCoral.opacity(0.3)),
                                   style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    }
                }
                .frame(width: geo.size.width, height: chartHeight)

                // Bars
                HStack(alignment: .bottom, spacing: sp) {
                    ForEach(days) { day in
                        let isToday = Calendar.current.isDateInToday(day.id)
                        let ratio = min(1.0, max(0, Double(day.sessionCount) / chartMax))
                        VStack(spacing: 3) {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(isToday ? Color.bbCoralDeep : Color.bbCoral.opacity(0.7))
                                .frame(width: bw,
                                       height: day.sessionCount == 0 ? 2 : max(4, CGFloat(ratio) * barAreaH))
                            Text(dayLabel(for: day.id, count: count))
                                .font(.system(size: count > 14 ? 7 : 8, weight: .bold, design: .rounded))
                                .foregroundStyle(isToday ? Color.bbCoralDeep : FeedingPosterPalette.inkMute)
                                .frame(width: bw, height: labelHeight)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                }
                .frame(width: geo.size.width, height: chartHeight, alignment: .bottomLeading)
            }
        }
        .frame(height: chartHeight)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        let filled = days.filter { $0.sessionCount > 0 }
        let total = days.map(\.sessionCount).reduce(0, +)
        let avgPerDay = filled.isEmpty ? 0.0
            : Double(total) / Double(days.count)
        let avgDur = total == 0 ? 0
            : days.map(\.totalMinutes).reduce(0, +) / total

        let avgTxt = String(format: "%.1f", avgPerDay)
        let totalTxt = "\(total)"
        let durTxt = "\(avgDur) \(loc.strings.unitMinShort)"

        return HStack(spacing: 0) {
            miniStat(top: loc.strings.feedingAvgPerDay, value: avgTxt, valueColor: .bbCoralDeep)
            Divider().frame(height: 28).overlay(Color.bbCoral.opacity(0.3))
            miniStat(top: loc.strings.feedingTotalSessions, value: totalTxt, valueColor: FeedingPosterPalette.ink)
            Divider().frame(height: 28).overlay(Color.bbCoral.opacity(0.3))
            miniStat(top: loc.strings.feedingAvgDuration, value: durTxt, valueColor: .bbCoralDeep)
        }
        .padding(.vertical, 8)
        .background(Color.bbCoral.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func miniStat(top: String, value: String, valueColor: Color) -> some View {
        VStack(spacing: 2) {
            Text(top)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundStyle(FeedingPosterPalette.inkMute)
                .kerning(0.3)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "drop")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Color.bbCoral)
            Text(loc.strings.feedingNoData)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(FeedingPosterPalette.inkMute)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Helpers

    private func dayLabel(for date: Date, count: Int) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: Language.localeIdentifier(for: lang))
        if selectedPeriod == 0 {
            df.dateFormat = "EEE"
            return String(df.string(from: date).prefix(2))
        } else {
            let day = Calendar.current.component(.day, from: date)
            if day == 1 || day % 7 == 1 {
                df.dateFormat = "d"
                return df.string(from: date)
            }
            return ""
        }
    }
}
