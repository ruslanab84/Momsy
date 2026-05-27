import SwiftUI

struct SleepView: View {
    @ObservedObject var vm: SleepViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager
    @State private var showAddManual = false

    var body: some View {
        ZStack {
            Color.bbLilac.ignoresSafeArea()
            Circle()
                .fill(Color.bbLilacDeep.opacity(0.18))
                .frame(width: 200)
                .offset(x: 80, y: -200)
                .ignoresSafeArea()
            Circle()
                .fill(Color.bbMint.opacity(0.15))
                .frame(width: 220)
                .offset(x: -120, y: 160)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    statsRow
                    timerBlock
                    if vm.isSleepActive { qualityPicker }
                    actionButton
                    todayList
                    SleepChartSection(
                        days: vm.sleepDays,
                        normMin: vm.sleepNorm.min,
                        normMax: vm.sleepNorm.max,
                        selectedPeriod: $vm.selectedChartPeriod,
                        lang: loc.lang
                    )
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .errorToast($vm.saveError)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.syncTimerWithStartDate() }
        }
        .sheet(isPresented: $showAddManual) {
            AddSleepEntrySheet(vm: vm)
                .environmentObject(loc)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.sleepTracker)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .kerning(0.5)
                Text(loc.strings.sleep)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            Button { showAddManual = true } label: {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 32)
                    .overlay(
                        Text(loc.strings.enterManuallyLabel)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                    )
            }
            .buttonStyle(.plain)
            Button { dismiss() } label: {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(
                label: loc.strings.totalToday,
                value: vm.totalSleepToday
            )
            Rectangle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 1, height: 44)
            statCell(
                label: loc.strings.sessions,
                value: "\(vm.todayEntries.filter { $0.endDate != nil }.count)"
            )
        }
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Timer Block

    private var timerBlock: some View {
        VStack(spacing: 8) {
            if vm.isSleepActive {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 8, height: 8)
                    Text(loc.strings.sleeping)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Text(vm.sleepTimerString)
                    .font(.system(size: 60, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: vm.sleepSeconds)
            } else {
                Text(vm.lastSleepDurationString)
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text(vm.lastSleepSubtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Quality Picker

    private var qualityPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.sleepQuality)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .kerning(0.5)
            HStack(spacing: 8) {
                ForEach(SleepQuality.allCases, id: \.self) { q in
                    Button {
                        withAnimation(.spring(response: 0.3)) { vm.selectedQuality = q }
                    } label: {
                        Text(qualityLabel(q))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(vm.selectedQuality == q ? .bbLilacDeep : .white.opacity(0.85))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(vm.selectedQuality == q ? Color.white : Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25), value: vm.selectedQuality)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if vm.isSleepActive { vm.stop() } else { vm.start() }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: vm.isSleepActive ? "stop.fill" : "moon.fill")
                    .font(.system(size: 16, weight: .bold))
                Text(vm.isSleepActive ? loc.strings.stopSleep : loc.strings.sleep)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
            }
            .foregroundColor(vm.isSleepActive ? .bbLilacDeep : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(vm.isSleepActive ? Color.white : Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .animation(.easeInOut(duration: 0.2), value: vm.isSleepActive)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today List

    private var todayList: some View {
        let completed = vm.todayEntries.filter { $0.endDate != nil }.reversed() as [SleepEntry]
        return Group {
            if !completed.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text(loc.strings.todayUpper)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .kerning(0.5)
                        .padding(.bottom, 10)
                    ForEach(Array(completed.enumerated()), id: \.element.id) { idx, entry in
                        HStack(spacing: 12) {
                            Text(timeString(entry.startDate))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.65))
                                .frame(width: 46, alignment: .leading)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entryDurationString(entry))
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                Text(qualityLabel(entry.quality))
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        if idx < completed.count - 1 {
                            Divider().overlay(Color.white.opacity(0.15))
                        }
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private func qualityLabel(_ q: SleepQuality) -> String {
        switch q {
        case .good:     return loc.strings.qualityGood
        case .normal:   return loc.strings.qualityNormal
        case .restless: return loc.strings.qualityRestless
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func entryDurationString(_ entry: SleepEntry) -> String {
        guard let mins = entry.durationMinutes else { return "—" }
        if mins < 60 { return loc.lang == "en" ? "\(mins) min" : "\(mins) мин" }
        let h = mins / 60, m = mins % 60
        if loc.lang == "en" { return m == 0 ? "\(h)h" : "\(h)h \(m)m" }
        return m == 0 ? "\(h) ч" : "\(h) ч \(m) м"
    }
}

#Preview {
    let container = AppContainer()
    SleepView(vm: container.makeSleepViewModel())
        .environmentObject(LocalizationManager.shared)
}
