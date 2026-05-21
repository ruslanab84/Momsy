import SwiftUI

struct TodayView: View {
    @StateObject private var vm: TodayViewModel
    @StateObject private var sleepVM: SleepViewModel
    @State private var showFeeding = false
    @State private var showSymptom = false
    @State private var showSleep = false
    @State private var now = Date()

    init(container: AppContainer) {
        _vm      = StateObject(wrappedValue: container.makeTodayViewModel())
        _sleepVM = StateObject(wrappedValue: container.makeSleepViewModel())
    }

    @AppStorage("babyName")      private var babyName = ""
    @AppStorage("babyBirthDate") private var babyBirthDateInterval: Double = 0
    @EnvironmentObject var loc: LocalizationManager


    private var displayName: String { babyName.isEmpty ? loc.t("Baby", "Малыш") : babyName }

    private var babyAgeString: String {
        guard babyBirthDateInterval > 0 else { return "" }
        let birth = Date(timeIntervalSince1970: babyBirthDateInterval)
        let comps = Calendar.current.dateComponents([.month, .day], from: birth, to: Date())
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        if loc.lang == "en" {
            if m == 0 { return "\(d)d" }
            if d == 0 { return "\(m)mo" }
            return "\(m)mo \(d)d"
        } else {
            if m == 0 { return "\(d) дн" }
            if d == 0 { return "\(m) мес" }
            return "\(m) мес \(d) дн"
        }
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: now)
        switch h {
        case 0..<5:   return loc.t("Good night,", "Доброй ночи,")
        case 5..<12:  return loc.t("Good morning,", "Доброе утро,")
        case 12..<18: return loc.t("Good afternoon,", "Добрый день,")
        default:      return loc.t("Good evening,", "Добрый вечер,")
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
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                now = Date()
            }
        }
        .sheet(isPresented: $showFeeding) {
            FeedingView(vm: vm)
        }
        .sheet(isPresented: $showSymptom) {
            NavigationStack { SymptomView() }
        }
        .sheet(isPresented: $showSleep) {
            SleepView(vm: sleepVM)
        }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 10) {
            CuteBlobView(kind: .baby, size: 44, tone: .bbCoral)
            VStack(alignment: .leading, spacing: 0) {
                Text(displayName)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                if !babyAgeString.isEmpty {
                    Text(babyAgeString)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
            }
            Spacer()
            BBPill(text: loc.t("Leap #4", "Скачок №4"), color: Color.bbLilac.opacity(0.6), fg: .bbLilacDeep, size: 12)
        }
        .padding(.top, 8)
    }

    // MARK: - Greeting

    private var greetingBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(loc.t("how did \(displayName) sleep?", "как \(displayName) спал?"))
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
                Text(loc.t("FEEDING", "КОРМЛЕНИЕ"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.bbInk.opacity(0.6))
                    .kerning(0.5)

                if vm.isFeedingActive {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(vm.feedingTimerString)
                            .font(.system(size: 32, weight: .heavy, design: .monospaced))
                            .foregroundColor(.bbInk)
                            .contentTransition(.numericText())
                            .animation(.linear(duration: 0.3), value: vm.feedingSeconds)
                        Text(loc.t("active · \(vm.feedingSide.displayName(lang: loc.lang).lowercased())",
                               "идёт · \(vm.feedingSide.rawValue.lowercased())"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color.bbInk.opacity(0.6))
                    }
                    Text(loc.t("Typical length — 18 min. Tap pause or stop.",
                           "Обычная длина — 18 мин. Нажмите паузу или стоп."))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                } else {
                    Text(vm.lastFeedAgoString)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(loc.t("Usually around this time — tap to start.",
                           "Обычно в это время — нажмите для старта."))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                }
            }

            Spacer(minLength: 8)

            if vm.isFeedingActive {
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
                    Button(action: { vm.stopFeeding() }) {
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
            if vm.isFeedingActive {
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
            Text(loc.t("Sleep", "Сон"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            if sleepVM.isSleepActive {
                Text(sleepVM.sleepTimerString)
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundColor(.bbLilacDeep)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.3), value: sleepVM.sleepSeconds)
                Text(loc.t("sleeping…", "спит…"))
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
            Text(loc.t("Diapers", "Подгузники"))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            Text(loc.t("\(vm.diaperCount) / day", "\(vm.diaperCount) / день"))
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
                Text(loc.t("Tip of the day", "Подсказка дня"))
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
        if vm.isFeedingActive {
            return loc.t("Feeding has been going for \(vm.feedingTimerString). Typical length is 18 min.",
                     "Кормление идёт уже \(vm.feedingTimerString). Обычная длина — 18 мин.")
        }
        let lastFeed = vm.logEntries.first(where: { $0.kind == .bottle })?.time
        let mins = lastFeed.map { max(0, Int(-$0.timeIntervalSinceNow / 60)) } ?? 0
        if mins >= 150 {
            return loc.t("\(vm.lastFeedAgoString) since last feeding — \(displayName) usually eats now. If crying — try breast first.",
                     "Прошло \(vm.lastFeedAgoString) с прошлого кормления — обычно \(displayName) ест в это время. Если плачет — попробуйте сначала грудь.")
        }
        return loc.t("During this leap \(displayName) is especially drawn to contrasts — show a black-and-white book.",
                 "В этот скачок \(displayName) особенно интересны контрасты — покажите чёрно-белую книжку.")
    }

    // MARK: - Leap Card

    private var leapCard: some View {
        HStack(spacing: 12) {
            CuteBlobView(kind: .moon, size: 48, tone: .bbLilac)
            VStack(alignment: .leading, spacing: 2) {
                Text(loc.t("LEAP #4 · DAY 3 OF ~5", "СКАЧОК №4 · ДЕНЬ 3 ИЗ ~5"))
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbLilacDeep)
                    .kerning(0.4)
                Text(loc.t("«World of Events» — this is normal", "«Мир событий» — это нормально"))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(loc.t("Crying, poor sleep, wants to be held. Not sick — growing.",
                        "Плачет, плохо спит, просит руки. Он не болен — он растёт."))
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
            QuickItem(kind: .bottle, tone: .bbCoral, label: loc.t("Feed", "Еда"))        { showFeeding = true },
            QuickItem(kind: .sleep,  tone: .bbLilac, label: loc.t("Sleep", "Сон"))       { showSleep = true },
            QuickItem(kind: .drop,   tone: .bbSky,   label: loc.t("Diaper", "Памп"))     { vm.logDiaper() },
            QuickItem(kind: .heart,  tone: .bbRose,  label: loc.t("Symptom", "Симптом")) { showSymptom = true },
        ]
    }

    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: loc.t("Quick log", "Быстро записать"))
            HStack(spacing: 8) {
                ForEach(quickItems, id: \.label) { item in
                    Button(action: item.action) {
                        VStack(spacing: 6) {
                            CuteBlobView(kind: item.kind, size: 36, tone: item.tone)
                            Text(item.label)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .bbShadowSoft()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - History Card

    private var historyCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text(loc.t("Today so far", "Сегодня уже было"))
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text(loc.t("\(vm.logEntries.count) entries", "\(vm.logEntries.count) записей"))
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
