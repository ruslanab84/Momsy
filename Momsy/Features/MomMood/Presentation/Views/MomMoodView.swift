import SwiftUI

struct MomMoodView: View {
    @StateObject private var vm: MomMoodViewModel
    @StateObject private var sleepVM: MomSleepViewModel
    @EnvironmentObject private var lm: LocalizationManager
    @State private var showMomSleep = false

    init(container: AppContainer) {
        _vm      = StateObject(wrappedValue: container.makeMomMoodViewModel())
        _sleepVM = StateObject(wrappedValue: container.makeMomSleepViewModel())
    }

    private let faces = ["😔", "😕", "😐", "🙂", "😊"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                checkinCard
                sleepCard
                if vm.shouldPromptEPDS {
                    epdsPromptCard
                } else if let score = vm.latestEPDSScore {
                    epdsScoreBadge(score: score)
                }
                historySection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.momMoodTitle)
        .task { await vm.loadHistory() }
        .sheet(isPresented: $showMomSleep) {
            MomSleepView(vm: sleepVM)
                .environmentObject(lm)
        }
        .sheet(item: $vm.activeSheet) { sheet in
            switch sheet {
            case .checkin: MoodCheckinSheet(vm: vm)
            case .epds:    EPDSSheet(vm: vm)
            }
        }
        .errorToast($vm.saveError)
    }

    // MARK: - Check-in Card

    private var checkinCard: some View {
        Button { vm.activeSheet = .checkin } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.bbRose.opacity(0.35))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text("🌸").font(.system(size: 24))
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        BBSectionLabel(text: lm.strings.momMoodSectionLabel)
                        Text(lm.strings.momMoodTodayPrompt)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInk)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.bbInkSoft)
                }
                Text(lm.strings.momMoodCheckinSub)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            .padding(18)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .bbShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sleep Card

    private var sleepCard: some View {
        Button { showMomSleep = true } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.bbRoseDeep.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: sleepVM.isSleepActive ? "moon.zzz.fill" : "moon.stars.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.bbRoseDeep)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    BBSectionLabel(text: lm.strings.momSleepTitle.uppercased())
                    Text(sleepVM.isSleepActive
                         ? "\(lm.strings.sleeping) \(sleepVM.sleepTimerString)"
                         : sleepVM.lastSleepDurationString)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                        .contentTransition(.numericText())
                }
                Spacer()
                if sleepVM.isSleepActive {
                    Circle()
                        .fill(Color.bbRoseDeep)
                        .frame(width: 10, height: 10)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.bbInkSoft)
            }
            .padding(18)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .bbShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - EPDS Prompt

    private var epdsPromptCard: some View {
        Button { vm.activeSheet = .epds } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.bbRoseDeep.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.bbRoseDeep)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(lm.strings.epdsTitle)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(lm.strings.epdsSubtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
                Spacer()
                Text(lm.strings.epdsStartCTA)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.bbRoseDeep)
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func epdsScoreBadge(score: Int) -> some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(vm.epdsRiskColor)
            Text("\(lm.strings.epdsLastScore): \(score)/30")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Spacer()
            Button { vm.activeSheet = .epds } label: {
                Text(lm.strings.epdsStartCTA)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.bbRoseDeep)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            BBSectionLabel(text: lm.strings.momMoodHistory)

            if vm.entries.isEmpty {
                emptyState
            } else {
                moodChart
                entryList
            }
        }
    }

    private var moodChart: some View {
        let days = last30Days()
        let entryMap = Dictionary(vm.entries.map {
            (Calendar.current.startOfDay(for: $0.date), $0.mood)
        }, uniquingKeysWith: { first, _ in first })
        return VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                let count = max(1, days.count)
                let sp: CGFloat = 2
                let bw = max(4, (geo.size.width - sp * CGFloat(count - 1)) / CGFloat(count))
                HStack(alignment: .bottom, spacing: sp) {
                    ForEach(days, id: \.self) { day in
                        let moodVal = entryMap[day] ?? 0
                        let ratio = CGFloat(moodVal) / 5.0
                        VStack(spacing: 2) {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(moodVal > 0 ? Color.bbRoseDeep : Color.bbInkMute.opacity(0.12))
                                .frame(width: bw, height: moodVal == 0 ? 2 : max(4, ratio * 80))
                        }
                    }
                }
                .frame(height: 90, alignment: .bottom)
            }
            .frame(height: 90)
        }
        .padding(14)
        .background(Color.bbRose.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func last30Days() -> [Date] {
        let cal = Calendar.current
        return (0..<30).compactMap { offset in
            cal.date(byAdding: .day, value: -(29 - offset), to: cal.startOfDay(for: Date()))
        }
    }

    private var entryList: some View {
        VStack(spacing: 1) {
            ForEach(vm.entries.prefix(10)) { entry in
                HStack(spacing: 12) {
                    Text(faces[entry.mood - 1])
                        .font(.system(size: 22))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entryDateLabel(entry.date))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.bbInk)
                        if !entry.note.isEmpty {
                            Text(entry.note)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    if let score = entry.epdsScore {
                        Text("EPDS \(score)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(epdsColor(score))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(epdsColor(score).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.bbCard)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }

    private func entryDateLabel(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return lm.strings.today }
        if cal.isDateInYesterday(date) { return lm.strings.yesterday }
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }

    private func epdsColor(_ score: Int) -> Color {
        if score >= 13 { return .bbCoral }
        if score >= 10 { return .bbButter }
        return .bbMint
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("🌸").font(.system(size: 48))
            Text(lm.strings.momMoodNoData)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
