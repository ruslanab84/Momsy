import SwiftUI

struct SleepChartSection: View {
    let days: [SleepDayPoint]
    let normMin: Double
    let normMax: Double
    @Binding var selectedPeriod: Int
    let lang: String

    @EnvironmentObject private var loc: LocalizationManager

    private let chartMax: Double = 18
    private let chartHeight: CGFloat = 150
    private let labelHeight: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            periodPicker
            if days.isEmpty || days.allSatisfy({ $0.totalMinutes == 0 }) {
                emptyState
            } else {
                chart
                statsRow
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text(loc.strings.sleepChartTitle.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
            Spacer()
            normBadge
        }
    }

    private var normBadge: some View {
        let label = lang == "en"
            ? "\(Int(normMin))–\(Int(normMax))h"
            : "\(Int(normMin))–\(Int(normMax)) ч"
        return Text(label)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(.bbMintDeep)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.bbMint.opacity(0.25))
            .clipShape(Capsule())
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 8) {
            chip(title: loc.strings.sleepPeriodWeek, index: 0)
            chip(title: loc.strings.sleepPeriodMonth, index: 1)
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
                .foregroundColor(selectedPeriod == index ? .white : .bbInkSoft)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedPeriod == index ? Color.bbLilacDeep : Color.bbLilac.opacity(0.15))
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
                // Norm band + gridlines via Canvas
                Canvas { ctx, size in
                    let areaH = size.height - labelHeight

                    // Norm band
                    let normTopY = (1 - min(chartMax, normMax) / chartMax) * areaH
                    let normBotY = (1 - max(0, normMin) / chartMax) * areaH
                    if normBotY > normTopY {
                        ctx.fill(
                            Path(CGRect(x: 0, y: normTopY,
                                        width: size.width, height: normBotY - normTopY)),
                            with: .color(.bbMint.opacity(0.22))
                        )
                    }

                    // Gridlines at 6h and 12h
                    for gridH in [6.0, 12.0] {
                        let y = (1 - gridH / chartMax) * areaH
                        var p = Path()
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                        ctx.stroke(p, with: .color(.bbLilac.opacity(0.5)),
                                   style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    }
                }
                .frame(width: geo.size.width, height: chartHeight)

                // Bars
                HStack(alignment: .bottom, spacing: sp) {
                    ForEach(days) { day in
                        let isToday = Calendar.current.isDateInToday(day.id)
                        let ratio = min(1.0, max(0, day.totalHours / chartMax))
                        VStack(spacing: 3) {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(isToday ? Color.bbLilacDeep : Color.bbLilac)
                                .frame(width: bw,
                                       height: day.totalMinutes == 0 ? 2 : max(4, CGFloat(ratio) * barAreaH))
                            Text(dayLabel(for: day.id, count: count))
                                .font(.system(size: count > 14 ? 7 : 8, weight: .bold, design: .rounded))
                                .foregroundColor(isToday ? .bbLilacDeep : .bbInkMute)
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
        let filled = days.filter { $0.totalMinutes > 0 }
        let avg = filled.isEmpty ? 0.0 : filled.map(\.totalHours).reduce(0, +) / Double(filled.count)
        let normMid = (normMin + normMax) / 2
        let diff = avg - normMid
        let isIn = avg >= normMin && avg <= normMax

        let avgTxt = lang == "en" ? String(format: "%.1fh", avg) : String(format: "%.1f ч", avg)
        let normTxt = lang == "en" ? "\(Int(normMin))–\(Int(normMax))h" : "\(Int(normMin))–\(Int(normMax)) ч"
        let diffTxt = lang == "en"
            ? String(format: "%+.1fh", diff)
            : String(format: "%+.1f ч", diff)
        let statusTxt = isIn ? loc.strings.sleepInNorm
            : (diff < 0 ? loc.strings.sleepBelowNorm : loc.strings.sleepAboveNorm)
        let diffColor: Color = isIn ? .bbMintDeep : (diff < 0 ? Color(UIColor.systemOrange) : .bbMintDeep)

        return HStack(spacing: 0) {
            miniStat(top: loc.strings.sleepAverage, value: avgTxt, valueColor: .bbLilacDeep)
            Divider().frame(height: 28).overlay(Color.bbLilac.opacity(0.4))
            miniStat(top: loc.strings.sleepNormLabel, value: normTxt, valueColor: .bbInk)
            Divider().frame(height: 28).overlay(Color.bbLilac.opacity(0.4))
            miniStat(top: statusTxt, value: diffTxt, valueColor: diffColor)
        }
        .padding(.vertical, 8)
        .background(Color.bbLilac.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func miniStat(top: String, value: String, valueColor: Color) -> some View {
        VStack(spacing: 2) {
            Text(top)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.3)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.bbLilac)
            Text(loc.strings.sleepNoData)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkMute)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Helpers

    private func dayLabel(for date: Date, count: Int) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: lang == "en" ? "en_US" : "ru_RU")
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
