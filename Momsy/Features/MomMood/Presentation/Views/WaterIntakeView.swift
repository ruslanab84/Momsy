import SwiftUI

struct WaterIntakeView: View {
    @ObservedObject var vm: WaterIntakeViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject private var units: UnitSystemManager

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    statsCard
                    quickAddRow
                    weeklyChart
                    entryList
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .task { await vm.load() }
        .errorToast($vm.saveError)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.waterIntakeLabel)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .kerning(0.5)
                Text(loc.strings.waterIntakeTitle)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbSkyDeep)
            }
            Spacer()
            Button { dismiss() } label: {
                Circle()
                    .fill(Color.bbSky.opacity(0.25))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.bbSkyDeep)
                    )
            }
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(vm.todayTotalMl)")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbSkyDeep)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: vm.todayTotalMl)
                Text(loc.strings.mlUnit)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.bbSkyDeep.opacity(0.7))
                    .padding(.bottom, 8)
            }

            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.bbSky.opacity(0.25))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.bbSkyDeep)
                            .frame(width: max(0, geo.size.width * vm.goalFraction), height: 10)
                            .animation(.spring(response: 0.4), value: vm.goalFraction)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text(loc.strings.waterTodayLabel)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                    Spacer()
                    Text("\(loc.strings.waterGoalLabel): \(vm.dailyGoalMl) \(loc.strings.mlUnit)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
            }
        }
        .padding(18)
        .background(Color.bbSky.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Quick Add

    private var quickAddRow: some View {
        HStack(spacing: 10) {
            quickAddButton(label: loc.strings.waterAdd150, amount: 150)
            quickAddButton(label: loc.strings.waterAdd250, amount: 250)
            quickAddButton(label: loc.strings.waterAdd500, amount: 500)
        }
    }

    private func quickAddButton(label: String, amount: Int) -> some View {
        Button {
            Task { await vm.log(amountMl: amount) }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 11, weight: .bold))
                Text(label)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.bbSkyDeep)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.bbSky.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.waterWeekLabel)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            GeometryReader { geo in
                let count = max(1, vm.weeklyDayTotals.count)
                let sp: CGFloat = 6
                let bw = max(8, (geo.size.width - sp * CGFloat(count - 1)) / CGFloat(count))
                let maxVal = max(vm.dailyGoalMl, vm.weeklyDayTotals.max() ?? vm.dailyGoalMl)
                let chartH: CGFloat = 80

                ZStack(alignment: .bottom) {
                    // Goal line
                    Rectangle()
                        .fill(Color.bbSkyDeep.opacity(0.3))
                        .frame(height: 1)
                        .offset(y: -chartH * CGFloat(vm.dailyGoalMl) / CGFloat(maxVal))

                    HStack(alignment: .bottom, spacing: sp) {
                        ForEach(vm.weeklyDayTotals.indices, id: \.self) { i in
                            let val = vm.weeklyDayTotals[i]
                            let ratio = CGFloat(val) / CGFloat(maxVal)
                            VStack(spacing: 3) {
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(i == 6 ? Color.bbSkyDeep : Color.bbSkyDeep.opacity(0.45))
                                    .frame(width: bw, height: val == 0 ? 2 : max(4, ratio * chartH))
                                Text(weekdayLabel(offsetFromToday: i - 6))
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(i == 6 ? .bbSkyDeep : .bbInkMute)
                            }
                        }
                    }
                    .frame(height: chartH, alignment: .bottom)
                }
                .frame(height: chartH + 16, alignment: .bottom)
            }
            .frame(height: 96)
        }
        .padding(14)
        .background(Color.bbSky.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func weekdayLabel(offsetFromToday: Int) -> String {
        guard let date = Calendar.current.date(byAdding: .day, value: offsetFromToday, to: Date()) else { return "" }
        let df = DateFormatter()
        df.locale = Locale(identifier: loc.lang)
        df.dateFormat = "EEE"
        return String(df.string(from: date).prefix(2))
    }

    // MARK: - Entry List

    private var entryList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.waterTodayEntriesLabel)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)

            if vm.todayEntries.isEmpty {
                Text(loc.strings.waterNoEntries)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 1) {
                    ForEach(vm.todayEntries.reversed().prefix(10)) { entry in
                        HStack(spacing: 12) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.bbSkyDeep)
                                .frame(width: 32)
                            Text(entry.date, format: units.current.timeFormatStyle())
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                            Spacer()
                            Text("\(entry.amountMl) \(loc.strings.mlUnit)")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbSkyDeep)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.bbCard)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
            }
        }
    }
}
