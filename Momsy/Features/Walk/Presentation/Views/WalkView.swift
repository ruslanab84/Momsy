import SwiftUI

struct WalkView: View {
    @ObservedObject var vm: WalkViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        ZStack {
            Color.bbMint.ignoresSafeArea()
            Circle()
                .fill(Color.bbMintDeep.opacity(0.18))
                .frame(width: 200)
                .offset(x: 80, y: -200)
                .ignoresSafeArea()
            Circle()
                .fill(Color.bbSky.opacity(0.15))
                .frame(width: 220)
                .offset(x: -120, y: 160)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    statsRow
                    timerBlock
                    actionButton
                    todayList
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
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.walkTracker)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .kerning(0.5)
                Text(loc.strings.walk)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
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
                value: vm.totalWalksToday
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
            if vm.isWalkActive {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 8, height: 8)
                    Text(loc.strings.walking)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Text(vm.walkTimerString)
                    .font(.system(size: 60, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: vm.walkSeconds)
            } else {
                Text(vm.lastWalkDurationString)
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text(vm.lastWalkSubtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if vm.isWalkActive { vm.stop() } else { vm.start() }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: vm.isWalkActive ? "stop.fill" : "stroller")
                    .font(.system(size: 16, weight: .bold))
                Text(vm.isWalkActive ? loc.strings.stopWalk : loc.strings.startWalk)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
            }
            .foregroundColor(vm.isWalkActive ? .bbMintDeep : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(vm.isWalkActive ? Color.white : Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .animation(.easeInOut(duration: 0.2), value: vm.isWalkActive)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today List

    private var todayList: some View {
        let completed = vm.todayEntries.filter { $0.endDate != nil }.reversed() as [WalkEntry]
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
                                Text(loc.strings.walk)
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

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func entryDurationString(_ entry: WalkEntry) -> String {
        guard let mins = entry.durationMinutes else { return "—" }
        if mins < 60 { return loc.lang == "en" ? "\(mins) min" : "\(mins) мин" }
        let h = mins / 60, m = mins % 60
        if loc.lang == "en" { return m == 0 ? "\(h)h" : "\(h)h \(m)m" }
        return m == 0 ? "\(h) ч" : "\(h) ч \(m) м"
    }
}
