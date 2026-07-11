import SwiftUI
import Combine

private final class TodayFeatureViewModels: ObservableObject {
    let feeding: FeedingViewModel
    let sleep: SleepViewModel
    let walk: WalkViewModel
    let bath: BathViewModel
    let vitamin: VitaminViewModel
    let pumping: PumpingViewModel

    init(container: AppContainer) {
        feeding = container.makeFeedingViewModel()
        sleep = container.makeSleepViewModel()
        walk = container.makeWalkViewModel()
        bath = container.makeBathViewModel()
        vitamin = container.makeVitaminViewModel()
        pumping = container.makePumpingViewModel()
    }
}

struct TodayView: View {
    @StateObject private var vm: TodayViewModel
    @StateObject private var featureVMs: TodayFeatureViewModels
    @State private var showFeeding = false
    @State private var showSymptom = false
    @State private var showSleep = false
    @State private var showWalk = false
    @State private var showBath = false
    @State private var showVitamins = false
    @State private var showStool = false
    @State private var showPumping = false
    @State private var showAllEntries = false
    @State private var showAddChild = false
    @State private var now = Date()

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _vm         = StateObject(wrappedValue: container.makeTodayViewModel())
        _featureVMs = StateObject(wrappedValue: TodayFeatureViewModels(container: container))
    }

    private var feedingVM: FeedingViewModel { featureVMs.feeding }
    private var sleepVM: SleepViewModel { featureVMs.sleep }
    private var walkVM: WalkViewModel { featureVMs.walk }
    private var bathVM: BathViewModel { featureVMs.bath }
    private var vitaminVM: VitaminViewModel { featureVMs.vitamin }
    private var pumpingVM: PumpingViewModel { featureVMs.pumping }

    @Environment(\.scenePhase) private var scenePhase
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
        f.locale = Locale(identifier: loc.current.localeIdentifier)
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: now).capitalized
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                headerRow
                greetingBlock
                if let prediction = vm.nextSleep {
                    NextSleepCard(prediction: prediction)
                }
                mainCards
                dailyTipCard
                if vm.currentLeap != nil { leapCard }
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
        .task { await vm.fetchDailyTipIfNeeded() }
        .task { await vm.refreshForecast() }
        .task { feedingVM.restoreOrStartFeeding(side: .left) }
        .onChange(of: loc.current) { _, _ in Task { await vm.refreshTip() } }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                feedingVM.syncTimerWithStartDate()
                pumpingVM.syncTimerWithStartDate()
                Task { await vm.refreshForecast() }
            }
        }
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
                .onDisappear {
                    Task {
                        await vm.loadTodayEntries()
                        await vm.refreshForecast()
                    }
                }
        }
        .sheet(isPresented: $showWalk) {
            WalkView(vm: walkVM)
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .sheet(isPresented: $showBath) {
            BathView(vm: bathVM)
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .sheet(isPresented: $showVitamins) {
            VitaminView(vm: vitaminVM)
                .onAppear {
                    vitaminVM.onEntrySaved = { Task { await vm.loadTodayEntries() } }
                    vitaminVM.loadToday()
                }
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .sheet(isPresented: $showStool) {
            AddStoolEntrySheet { date in vm.logStool(date: date) }
                .environmentObject(loc)
        }
        .sheet(isPresented: $showAllEntries) {
            AllTodayEntriesView(entries: vm.logEntries)
                .environmentObject(loc)
        }
        .sheet(isPresented: $showPumping) {
            PumpingView(vm: pumpingVM)
                .environmentObject(loc)
                .onDisappear { Task { await vm.loadTodayEntries() } }
        }
        .sheet(isPresented: $showAddChild) {
            AddChildSheet { profile in
                Task { try? await container.addChild(profile) }
            }
            .environmentObject(loc)
        }
        .errorToast($vm.saveError)
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(appState.babies) { baby in
                    Button {
                        guard baby.id != appState.activeBabyId else { return }
                        Task { await container.switchActiveBaby(to: baby.id) }
                    } label: {
                        let title = baby.name.isEmpty ? loc.strings.baby : baby.name
                        if baby.id == appState.activeBabyId {
                            Label(title, systemImage: "checkmark")
                        } else {
                            Text(title)
                        }
                    }
                }
                if appState.babies.count < ActiveBaby.maxChildren {
                    Divider()
                    Button {
                        showAddChild = true
                    } label: {
                        Label(loc.strings.addChild, systemImage: "plus")
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    CuteBlobView(kind: .baby, size: 44, tone: .bbCoral)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Text(appState.displayName)
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInk)
                            if appState.babies.count > 1 {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.bbInkSoft)
                            }
                        }
                        if !appState.babyAgeString(lang: loc.lang).isEmpty {
                            Text(appState.babyAgeString(lang: loc.lang))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            Spacer()
            if let leap = vm.currentLeap {
                BBPill(text: loc.strings.leapPill(leap.id), color: Color.bbLilac.opacity(0.6), fg: .bbLilacDeep, size: 12)
            }
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
            TodayFeedingCard(
                vm: feedingVM,
                openFeeding: { showFeeding = true },
                reloadTodayEntries: { Task { await vm.loadTodayEntries() } }
            )
            HStack(spacing: 10) {
                TodaySleepCard(vm: sleepVM) { showSleep = true }
                TodayDiaperCard(
                    count: vm.diaperCount,
                    remove: { vm.removeDiaper() },
                    log: { vm.logDiaper() }
                )
            }
        }
    }

    // MARK: - Daily Tip Card

    private var tipCategory: TipCategory { vm.dailyTip?.category ?? .defaultTip }

    private var tipAccentColor: Color {
        switch tipCategory {
        case .alert:       return .bbCoralDeep
        case .situational: return .bbMintDeep
        case .care:        return .bbMintDeep
        case .development: return .bbLilacDeep
        case .defaultTip:  return .bbButterDeep
        }
    }

    private var tipCardBackground: Color {
        switch tipCategory {
        case .alert:       return Color.bbCoral.opacity(0.12)
        case .situational: return Color.bbMint.opacity(0.12)
        case .care:        return Color.bbCreamSoft
        case .development: return Color.bbLilac.opacity(0.12)
        case .defaultTip:  return Color.bbCreamSoft
        }
    }

    private var tipBadgeEmoji: String {
        switch tipCategory {
        case .alert:       return "⚠️"
        case .situational: return "💡"
        case .care:        return "🌿"
        case .development: return "⭐"
        case .defaultTip:  return "💛"
        }
    }

    private var dailyTipCard: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(tipAccentColor.opacity(0.15))
                .frame(width: 28, height: 28)
                .overlay(Text(tipBadgeEmoji).font(.system(size: 14)))

            VStack(alignment: .leading, spacing: 4) {
                Text(loc.strings.tipOfDay)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                dailyTipBody
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(pad: 14, bg: tipCardBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(tipAccentColor)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private var dailyTipBody: some View {
        if vm.isTipLoading && vm.dailyTip == nil {
            VStack(alignment: .leading, spacing: 4) {
                Text("Подбираем совет для вашего малыша...")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .redacted(reason: .placeholder)
                Text("Это займёт секунду.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .redacted(reason: .placeholder)
            }
        } else if let tip = vm.dailyTip {
            Text(tip.text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(loc.strings.leapContrastsTip(name: appState.displayName))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Leap Card

    private func leapTitle(for leap: DevelopmentLeap) -> String {
        if case .hardDays(let day, let total, _, _, _, _)? = vm.leapPhase {
            return loc.strings.leapDayCard(n: leap.id, day: day, total: total)
        }
        return loc.strings.leapNumberCard(leap.id)
    }

    private var leapNote: String {
        if case .hardDays? = vm.leapPhase { return loc.strings.leapCryingNote }
        return loc.strings.leapSettledNote
    }

    @ViewBuilder
    private var leapCard: some View {
        if let leap = vm.currentLeap {
            let title = leapTitle(for: leap)
            let note = leapNote
            HStack(spacing: 12) {
                CuteBlobView(kind: .moon, size: 48, tone: .bbLilac)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbLilacDeep)
                        .kerning(0.4)
                    Text(loc.strings.leapNormalLabel(name: vm.currentLeapName ?? ""))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(note)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .bbCard(pad: 14, bg: Color.bbLilac.opacity(0.3))
        }
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
            QuickItem(kind: .stool,   tone: .bbMint,   label: loc.strings.stoolLabel)  { showStool = true },
            QuickItem(kind: .heart,   tone: .bbRose,   label: loc.strings.symptom)     { showSymptom = true },
            QuickItem(kind: .walk,    tone: .bbMint,   label: loc.strings.walk)        { showWalk = true },
            QuickItem(kind: .bath,    tone: .bbSky,    label: loc.strings.bath)        { showBath = true },
            QuickItem(kind: .vitamin, tone: .bbButter, label: loc.strings.vitamins)    { showVitamins = true },
            QuickItem(kind: .pump,    tone: .bbRose,   label: loc.strings.pumping)     { showPumping = true },
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
            Button { showAllEntries = true } label: {
                HStack {
                    Text(loc.strings.todaySoFar)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Spacer()
                    Text(loc.strings.entriesCount(vm.logEntries.count))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.bbInkMute)
                        .padding(.leading, 2)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)

            VStack(spacing: 10) {
                ForEach(vm.logEntries.prefix(7)) { entry in
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

private struct TodayFeedingCard: View {
    @ObservedObject var vm: FeedingViewModel
    let openFeeding: () -> Void
    let reloadTodayEntries: () -> Void

    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(loc.strings.feedingLabel)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.bbInk.opacity(0.6))
                    .kerning(0.5)

                if vm.feedingSessionExists {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(vm.feedingTimerString)
                            .font(.system(size: 32, weight: .heavy, design: .monospaced))
                            .foregroundColor(.bbInk)
                            .contentTransition(.numericText())
                            .animation(.linear(duration: 0.3), value: vm.feedingSeconds)
                        Text(vm.isFeedingActive
                            ? loc.strings.feedingActiveLabel(side: vm.feedingSide.displayName(lang: loc.lang).lowercased())
                            : loc.strings.paused)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color.bbInk.opacity(0.6))
                    }
                    Text(loc.strings.typicalLengthHint)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                } else {
                    Text(vm.lastFeedAgoString)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.strings.usuallyAroundThisTime)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                }
            }

            Spacer(minLength: 8)

            if vm.feedingSessionExists {
                VStack(spacing: 8) {
                    Button(action: toggleFeeding) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 48, height: 48)
                            .overlay(playPauseIcon)
                            .bbShadowSoft()
                            .animation(.spring(response: 0.25), value: vm.isFeedingActive)
                    }
                    Button(action: stopFeeding) {
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
                Button(action: openFeeding) {
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
            if vm.feedingSessionExists {
                Circle()
                    .fill(vm.isFeedingActive ? Color.bbSurface : Color.bbCoralDeep.opacity(0.5))
                    .frame(width: 10, height: 10)
                    .padding(10)
                    .opacity(0.7)
            }
        }
    }

    @ViewBuilder
    private var playPauseIcon: some View {
        if vm.isFeedingActive {
            HStack(spacing: 3) {
                ForEach(0..<2) { _ in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color.bbCoralDeep)
                        .frame(width: 4, height: 16)
                }
            }
        } else {
            Image(systemName: "play.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.bbCoralDeep)
                .offset(x: 2)
        }
    }

    private func toggleFeeding() {
        if vm.isFeedingActive {
            vm.pauseFeeding()
        } else {
            vm.resumeFeeding()
        }
    }

    private func stopFeeding() {
        vm.stopFeeding()
        reloadTodayEntries()
    }
}

private struct TodaySleepCard: View {
    @ObservedObject var vm: SleepViewModel
    let openSleep: () -> Void

    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                CuteBlobView(kind: .sleep, size: 36, tone: .bbLilac)
                Spacer()
                if vm.isSleepActive {
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
            if vm.isSleepActive {
                Text(vm.sleepTimerString)
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundColor(.bbLilacDeep)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: vm.sleepSeconds)
                Text(loc.strings.sleeping)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            } else {
                Text(vm.lastSleepDurationString)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(vm.lastSleepSubtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(pad: 14)
        .animation(.spring(response: 0.3), value: vm.isSleepActive)
        .onTapGesture(perform: openSleep)
    }
}

private struct TodayDiaperCard: View {
    let count: Int
    let remove: () -> Void
    let log: () -> Void

    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CuteBlobView(kind: .drop, size: 36, tone: .bbSky)
            Text(loc.strings.diapers)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            Text(loc.strings.diaperCountDay(count))
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.35), value: count)
            HStack(spacing: 8) {
                Button(action: remove) {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(count > 0 ? .bbInkSoft : .bbInkMute.opacity(0.35))
                        .frame(width: 28, height: 28)
                        .background(Color.bbCreamSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(count == 0)
                .animation(.spring(response: 0.25), value: count)

                Button(action: log) {
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
}

#Preview {
    TodayView(container: AppContainer())
        .environmentObject(LocalizationManager.shared)
}
