import SwiftUI

struct LogReportView: View {
    @StateObject private var vm: LogReportViewModel
    @EnvironmentObject var loc: LocalizationManager

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeLogReportViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                modeChips
                if vm.mode == .day {
                    dayPickerCard
                } else {
                    periodNavigator
                }
                content
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .onChange(of: vm.mode) { _, _ in Task { await vm.load() } }
        .onChange(of: vm.selectedDate) { _, _ in Task { await vm.load() } }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: loc.strings.logReportTitle)
            Text(loc.strings.logReportSub)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Mode

    private var modeChips: some View {
        HStack(spacing: 8) {
            chip(loc.strings.logReportDay, mode: .day)
            chip(loc.strings.reportPeriodWeek, mode: .week)
            chip(loc.strings.reportPeriodMonth, mode: .month)
            Spacer()
        }
    }

    private func chip(_ title: String, mode: LogReportMode) -> some View {
        Button { vm.mode = mode } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(vm.mode == mode ? .white : .bbInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(vm.mode == mode ? Color.bbCoralDeep : Color.bbCard)
                .clipShape(Capsule())
                .bbShadowSoft()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Period controls

    private var dayPickerCard: some View {
        HStack {
            Text(vm.periodTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Spacer()
            DatePicker("", selection: $vm.selectedDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
        }
        .bbCard(pad: 12)
    }

    private var periodNavigator: some View {
        HStack {
            navButton("chevron.left") { vm.shift(-1) }
            Spacer()
            Text(vm.periodTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
                .contentTransition(.interpolate)
            Spacer()
            navButton("chevron.right") { vm.shift(1) }
        }
        .bbCard(pad: 12)
    }

    private func navButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.bbInkSoft)
                .frame(width: 34, height: 34)
                .background(Color.bbCream)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch vm.mode {
        case .day:
            LogReportDayList(items: vm.items, emptyText: loc.strings.logReportEmpty)
        case .week:
            LogReportWeekTimeline(vm: vm)
            selectedDayList
        case .month:
            LogReportMonthGrid(vm: vm)
            selectedDayList
        }
    }

    private var selectedDayList: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: vm.periodTitleForSelectedDay)
            LogReportDayList(items: vm.items(on: vm.selectedDate),
                             emptyText: loc.strings.logReportEmpty)
        }
    }
}

private extension LogReportViewModel {
    var periodTitleForSelectedDay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
}
