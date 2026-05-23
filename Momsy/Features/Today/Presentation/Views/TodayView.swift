import SwiftUI

struct TodayView: View {
    @StateObject private var vm: TodayViewModel
    @StateObject private var feedingVM: FeedingViewModel
    @StateObject private var sleepVM: SleepViewModel
    @StateObject private var walkVM: WalkViewModel
    @StateObject private var bathVM: BathViewModel
    @State private var showFeeding = false
    @State private var showSymptom = false
    @State private var showSleep = false
    @State private var showWalk = false
    @State private var showBath = false
    @State private var now = Date()

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _vm         = StateObject(wrappedValue: container.makeTodayViewModel())
        _feedingVM  = StateObject(wrappedValue: container.makeFeedingViewModel())
        _sleepVM    = StateObject(wrappedValue: container.makeSleepViewModel())
        _walkVM     = StateObject(wrappedValue: container.makeWalkViewModel())
        _bathVM     = StateObject(wrappedValue: container.makeBathViewModel())
    }

    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var appState: AppState

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: now)
        switch h {
        case 0..<5:   return loc.strings.goodNight
        case 5..<12:  return loc.strings.goodMorningGreeting
        case 12..<18: return loc.strings.goodAfternoonGreeting
        default:      return loc.strings.goodEveningGreeting
        }
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: loc.lang == "en" ? "en_US" : "ru_RU")
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: now).capitalized
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                headerRow
                greetingBlock
                mainCards
                aiTipCard
                leapCard
                quickLogSection
                historyCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .task { await vm.loadTodayEntries() }
        .task { await feedingVM.loadTodayEntries() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                now = Date()
            }
        }
        .sheet(isPresented: $showFeeding) {
            FeedingView(vm: feedingVM)
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .sheet(isPresented: $showSymptom) {
            NavigationStack { SymptomView(container: container) }
        }
        .sheet(isPresented: $showSleep) {
            SleepView(vm: sleepVM)
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .sheet(isPresented: $showWalk) {
            WalkView(vm: walkVM)
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .sheet(isPresented: $showBath) {
            BathView(vm: bathVM)
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .errorToast($vm.saveError)
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 10) {
            CuteBlobView(kind: .baby, size: 44, tone: .bbCoral)
            VStack(alignment: .leading, spacing: 0) {
                Text(appState.displayName)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                if !appState.babyAgeString(lang: loc.lang).isEmpty {
                    Text(appState.babyAgeString(lang: loc.lang))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
            }
            Spacer()
            BBPill(text: loc.strings.leapPillLabel, color: Color.bbLilac.opacity(0.6), fg: .bbLilacDeep, size: 12)
        }
        .padding(.top, 8)
    }

    // MARK: - Greeting

    private var greetingBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(loc.strings.howDidSleep(name: appState.displayName))
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbCoralDeep)
            Text(dateString)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Main Cards

    private var mainCards: some View {
        VStack(spacing: 10) {
            feedingCard
            HStack(spacing: 10) {
                sleepCard
                diaperCard
            }
        }
    }

    // MARK: - Feeding Card

    private var feedingCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(loc.strings.feedingLabel)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.bbInk.opacity(0.6))
                    .kerning(0.5)

                if feedingVM.isFeedingActive {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(feedingVM.feedingTimerString)
                            .font(.system(size: 32, weight: .heavy, design: .monospaced))
                            .foregroundColor(.bbInk)
                            .contentTransition(.numericText())
                            .animation(.linear(duration: 0.3), value: feedingVM.feedingSeconds)
                        Text(loc.strings.feedingActiveLabel(side: feedingVM.feedingSide.displayName(lang: loc.lang).lowercased()))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color.bbInk.opacity(0.6))
                    }
                    Text(loc.strings.typicalLengthHint)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                } else {
                    Text(feedingVM.lastFeedAgoString)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.strings.usuallyAroundThisTime)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                }
            }

            Spacer(minLength: 8)

            if feedingVM.isFeedingActive {
                VStack(spacing: 8) {
                    Button(action: { showFeeding = true }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 48, height: 48)
                            .overlay(
                                HStack(spacing: 3) {
                                    ForEach(0..<2) { _ in
                                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                                            .fill(Color.bbCoralDeep)
                                            .frame(width: 4, height: 16)
                                    }
                                }
                            )
                            .bbShadowSoft()
                    }
                    Button(action: {
                        feedingVM.stopFeeding()
                        Task { await vm.loadTodayEntries() }
                    }) {
                        Circle()
                            .fill(Color.bbSurface)
                            .frame(width: 48, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.white)
                                    .frame(width: 16, height: 16)
                            )
                    }
                }
            } else {
                Button(action: { showFeeding = true }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.06), radius: 2)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.bbCoralDeep)
                                .offset(x: 2)
                        )
                }
            }
        }
        .bbCard(pad: 14, bg: .bbCoral)
        .overlay(alignment: .topTrailing) {
            if feedingVM.isFeedingActive {
                Circle()
                    .fill(Color.bbSurface)
                    .frame(width: 10, height: 10)
                    .padding(10)
                    .opacity(0.7)
            }
        }
    }

    // MARK: - Sleep Card

    private var sleepCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                CuteBlobView(kind: .sleep, size: 36, tone: .bbLilac)
                Spacer()
                if sleepVM.isSleepActive {
                    Circle()
                        .fill(Color.bbLilacDeep)
                        .frame(width: 8, height: 8)
                        .padding(.top, 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            Text(loc.strings.sleep)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            if sleepVM.isSleepActive {
                Text(sleepVM.sleepTimerString)
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundColor(.bbLilacDeep)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: sleepVM.sleepSeconds)
                Text(loc.strings.sleeping)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            } else {
                Text(sleepVM.lastSleepDurationString)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(sleepVM.lastSleepSubtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(pad: 14)
        .animation(.spring(response: 0.3), value: sleepVM.isSleepActive)
        .onTapGesture { showSleep = true }
    }

    // MARK: - Diaper Card

    private var diaperCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            CuteBlobView(kind: .drop, size: 36, tone: .bbSky)
            Text(loc.strings.diapers)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            Text(loc.strings.diaperCountDay(vm.diaperCount))
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.35), value: vm.diaperCount)
            HStack(spacing: 8) {
                Button { vm.removeDiaper() } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(vm.diaperCount > 0 ? .bbInkSoft : .bbInkMute.opacity(0.35))
                        .frame(width: 28, height: 28)
                        .background(Color.bbCreamSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(vm.diaperCount == 0)
                .animation(.spring(response: 0.25), value: vm.diaperCount)

                Button { vm.logDiaper() } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.bbSkyDeep)
                        .frame(width: 28, height: 28)
                        .background(Color.bbSky.opacity(0.45))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(pad: 14)
    }

    // MARK: - AI Tip Card

    private var aiTipCard: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.bbButter)
                .frame(width: 28, height: 28)
                .overlay(
                    Text("AI")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbButterDeep)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.tipOfDay)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(aiTipText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .bbCard(pad: 14, bg: .bbCreamSoft)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.bbButterDeep)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var aiTipText: String {
        if feedingVM.isFeedingActive {
            return loc.strings.feedingDuration(feedingVM.feedingTimerString)
        }
        let lastFeed = vm.logEntries.first(where: { $0.kind == .bottle })?.time
        let mins = lastFeed.map { max(0, Int(-$0.timeIntervalSinceNow / 60)) } ?? 0
        if mins >= 150 {
            return loc.strings.feedingTip(ago: feedingVM.lastFeedAgoString, name: appState.displayName)
        }
        return loc.strings.leapContrastsTip(name: appState.displayName)
    }

    // MARK: - Leap Card

    private var leapCard: some View {
        HStack(spacing: 12) {
            CuteBlobView(kind: .moon, size: 48, tone: .bbLilac)
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.strings.leapDayCard)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbLilacDeep)
                    .kerning(0.4)
                Text(loc.strings.worldOfEventsLabel)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(loc.strings.leapCryingNote)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .bbCard(pad: 14, bg: Color.bbLilac.opacity(0.3))
    }

    // MARK: - Quick Log

    private struct QuickItem {
        let kind: BlobKind
        let tone: Color
        let label: String
        let action: () -> Void
    }

    private var quickItems: [QuickItem] {
        [
            QuickItem(kind: .bottle,  tone: .bbCoral,  label: loc.strings.feedLabel)   { showFeeding = true },
            QuickItem(kind: .sleep,   tone: .bbLilac,  label: loc.strings.sleep)       { showSleep = true },
            QuickItem(kind: .drop,    tone: .bbSky,    label: loc.strings.diaperQuick) { vm.logDiaper() },
            QuickItem(kind: .heart,   tone: .bbRose,   label: loc.strings.symptom)     { showSymptom = true },
            QuickItem(kind: .walk,    tone: .bbMint,   label: loc.strings.walk)        { showWalk = true },
            QuickItem(kind: .bath,    tone: .bbSky,    label: loc.strings.bath)        { showBath = true },
            QuickItem(kind: .vitamin, tone: .bbButter, label: loc.strings.vitamins)    { vm.logVitamins() },
        ]
    }

    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: loc.strings.quickLogLabel)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickItems, id: \.label) { item in
                        Button(action: item.action) {
                            VStack(spacing: 6) {
                                CuteBlobView(kind: item.kind, size: 36, tone: item.tone)
                                Text(item.label)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.bbInkSoft)
                            }
                            .frame(width: 70)
                            .padding(.vertical, 10)
                            .background(Color.bbCard)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .bbShadowSoft()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 1)
            }
        }
    }

    // MARK: - History Card

    private var historyCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text(loc.strings.todaySoFar)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text(loc.strings.entriesCount(vm.logEntries.count))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
            .padding(.bottom, 12)

            VStack(spacing: 10) {
                ForEach(vm.logEntries.prefix(6)) { entry in
                    HStack(spacing: 12) {
                        Text(entry.timeString)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.bbInkMute)
                            .frame(width: 44, alignment: .leading)
                        CuteBlobView(kind: entry.kind, size: 32, tone: entry.kind.defaultTone)
                        Text(entry.label)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInk)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
        }
        .bbCard(pad: 14)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.logEntries.count)
    }
}

#Preview {
    TodayView(container: AppContainer())
        .environmentObject(LocalizationManager.shared)
}
