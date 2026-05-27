import SwiftUI

struct MomSleepView: View {
    @ObservedObject var vm: MomSleepViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager
    @State private var showAddManual = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    statsRow
                    timerBlock
                    if vm.isSleepActive { qualityPicker }
                    actionButton
                    SleepChartSection(
                        days: vm.sleepDays,
                        normMin: vm.normMin,
                        normMax: vm.normMax,
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
            AddMomSleepEntrySheet(vm: vm)
                .environmentObject(loc)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.momSleepTitle.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .kerning(0.5)
                Text(loc.strings.sleep)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbRoseDeep)
            }
            Spacer()
            Button { showAddManual = true } label: {
                Text(loc.strings.enterManuallyLabel)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbRoseDeep)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.bbRose.opacity(0.25))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            Button { dismiss() } label: {
                Circle()
                    .fill(Color.bbRose.opacity(0.25))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.bbRoseDeep)
                    )
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(label: loc.strings.totalToday, value: vm.totalSleepToday)
            Rectangle()
                .fill(Color.bbRose.opacity(0.4))
                .frame(width: 1, height: 44)
            statCell(
                label: loc.strings.sessions,
                value: "\(vm.todayEntries.filter { $0.endDate != nil }.count)"
            )
        }
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.bbRoseDeep)
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
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
        .background(Color.bbRoseDeep)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Quality Picker

    private var qualityPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc.strings.sleepQuality)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkMute)
                .kerning(0.5)
            HStack(spacing: 8) {
                ForEach(SleepQuality.allCases, id: \.self) { q in
                    Button {
                        withAnimation(.spring(response: 0.3)) { vm.selectedQuality = q }
                    } label: {
                        Text(q.localizedLabel(loc.strings))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(vm.selectedQuality == q ? .bbRoseDeep : .bbInkSoft)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(vm.selectedQuality == q ? Color.white : Color.bbRose.opacity(0.25))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25), value: vm.selectedQuality)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.bbRose.opacity(0.15))
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
                Image(systemName: vm.isSleepActive ? "stop.fill" : "moon.stars.fill")
                    .font(.system(size: 16, weight: .bold))
                Text(vm.isSleepActive ? loc.strings.stopSleep : loc.strings.sleep)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
            }
            .foregroundColor(vm.isSleepActive ? .bbRoseDeep : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(vm.isSleepActive ? Color.bbRose.opacity(0.25) : Color.bbRoseDeep)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .animation(.easeInOut(duration: 0.2), value: vm.isSleepActive)
        }
        .buttonStyle(.plain)
    }
}
