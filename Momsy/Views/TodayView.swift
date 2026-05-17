import SwiftUI
import Combine

// MARK: - Log Entry

struct LogEntry: Identifiable {
    let id = UUID()
    let time: Date
    let kind: BlobKind
    let tone: Color
    let label: String

    var timeString: String { DateFormatter.bbTime.string(from: time) }
}

private extension DateFormatter {
    static let bbTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    static let bbDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEE, d MMMM"
        return f
    }()
}

// MARK: - ViewModel

final class TodayViewModel: ObservableObject {
    @Published var isFeedingActive = false
    @Published var feedingSeconds = 0
    @Published var feedingSide: FeedingSide = .left
    @Published var diaperCount = 5
    @Published var logEntries: [LogEntry]

    private var timerCancellable: AnyCancellable?

    init() {
        let cal = Calendar.current
        let today = Date()
        func t(_ h: Int, _ m: Int) -> Date {
            cal.date(bySettingHour: h, minute: m, second: 0, of: today) ?? today
        }
        logEntries = [
            LogEntry(time: t(6, 42), kind: .bottle, tone: .bbCoral,  label: "Кормление · 15 мин · правая"),
            LogEntry(time: t(5, 10), kind: .sleep,  tone: .bbLilac,  label: "Просыпание · спал 4 ч 12 мин"),
            LogEntry(time: t(4, 55), kind: .drop,   tone: .bbSky,    label: "Подгузник · мокрый"),
            LogEntry(time: t(1,  8), kind: .bottle, tone: .bbCoral,  label: "Кормление · 22 мин · левая"),
        ]
    }

    var feedingTimerString: String {
        String(format: "%02d:%02d", feedingSeconds / 60, feedingSeconds % 60)
    }

    var lastFeedAgoString: String {
        guard let last = logEntries.first(where: { $0.kind == .bottle }) else { return "нет данных" }
        let mins = max(0, Int(-last.time.timeIntervalSinceNow / 60))
        if mins < 60 { return "\(mins) мин назад" }
        let h = mins / 60, m = mins % 60
        return m == 0 ? "\(h) ч назад" : "\(h) ч \(m) мин назад"
    }

    func startFeeding(side: FeedingSide) {
        feedingSide = side
        isFeedingActive = true
        feedingSeconds = 0
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.feedingSeconds += 1 }
    }

    func stopFeeding() {
        guard isFeedingActive else { return }
        isFeedingActive = false
        timerCancellable?.cancel()
        timerCancellable = nil
        let dur = max(1, feedingSeconds / 60)
        let side = feedingSide.rawValue.lowercased()
        addEntry(LogEntry(time: Date(), kind: .bottle, tone: .bbCoral,
                          label: "Кормление · \(dur) мин · \(side)"))
    }

    func logDiaper() {
        diaperCount += 1
        addEntry(LogEntry(time: Date(), kind: .drop, tone: .bbSky,
                          label: "Подгузник #\(diaperCount) · мокрый"))
    }

    func logSleep() {
        addEntry(LogEntry(time: Date(), kind: .sleep, tone: .bbLilac, label: "Сон · начало"))
    }

    func logSymptom() {
        addEntry(LogEntry(time: Date(), kind: .heart, tone: .bbRose, label: "Симптом · записан"))
    }

    private func addEntry(_ entry: LogEntry) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            logEntries.insert(entry, at: 0)
        }
    }
}

// MARK: - TodayView

struct TodayView: View {
    @StateObject private var vm = TodayViewModel()
    @State private var showFeeding = false
    @State private var showSymptom = false
    @State private var now = Date()

    @AppStorage("babyName")      private var babyName = ""
    @AppStorage("babyBirthDate") private var babyBirthDateInterval: Double = 0

    private let minuteClock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var displayName: String { babyName.isEmpty ? "Малыш" : babyName }

    private var babyAgeString: String {
        guard babyBirthDateInterval > 0 else { return "" }
        let birth = Date(timeIntervalSince1970: babyBirthDateInterval)
        let comps = Calendar.current.dateComponents([.month, .day], from: birth, to: Date())
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        if m == 0 { return "\(d) дн" }
        if d == 0 { return "\(m) мес" }
        return "\(m) мес \(d) дн"
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: now)
        switch h {
        case 0..<5:  return "Доброй ночи,"
        case 5..<12: return "Доброе утро,"
        case 12..<18: return "Добрый день,"
        default:     return "Добрый вечер,"
        }
    }

    private var dateString: String {
        DateFormatter.bbDate.string(from: now).capitalized
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
        .onReceive(minuteClock) { now = $0 }
        .sheet(isPresented: $showFeeding) {
            FeedingView(vm: vm)
        }
        .sheet(isPresented: $showSymptom) {
            NavigationStack { SymptomView() }
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
            BBPill(text: "Скачок №4", color: Color.bbLilac.opacity(0.6), fg: .bbLilacDeep, size: 12)
        }
        .padding(.top, 8)
    }

    // MARK: - Greeting

    private var greetingBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text("как \(displayName) спал?")
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

    // MARK: - Feeding Card (live timer when active)

    private var feedingCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("КОРМЛЕНИЕ")
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
                        Text("идёт · \(vm.feedingSide.rawValue.lowercased())")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color.bbInk.opacity(0.6))
                    }
                    Text("Обычная длина — 18 мин. Нажмите паузу или стоп.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                } else {
                    Text(vm.lastFeedAgoString)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text("Обычно в это время — нажмите для старта.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.bbInk.opacity(0.6))
                }
            }

            Spacer(minLength: 8)

            if vm.isFeedingActive {
                // Pause / stop buttons
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
                            .fill(Color.bbInk)
                            .frame(width: 48, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.white)
                                    .frame(width: 16, height: 16)
                            )
                    }
                }
            } else {
                // Play button
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
                    .fill(Color.bbInk)
                    .frame(width: 10, height: 10)
                    .padding(10)
                    .opacity(0.7)
            }
        }
    }

    // MARK: - Sleep Card

    private var sleepCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            CuteBlobView(kind: .sleep, size: 36, tone: .bbLilac)
            Text("Сон")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            Text("~ 40 мин")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text("до следующего")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkMute)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(pad: 14)
        .onTapGesture { vm.logSleep() }
    }

    // MARK: - Diaper Card

    private var diaperCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            CuteBlobView(kind: .drop, size: 36, tone: .bbSky)
            Text("Подгузники")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            Text("\(vm.diaperCount) / день")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.35), value: vm.diaperCount)
            Text("+ нажать, чтоб добавить")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkMute)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bbCard(pad: 14)
        .onTapGesture { vm.logDiaper() }
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
                Text("Подсказка дня")
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
            return "Кормление идёт уже \(vm.feedingTimerString). Обычная длина — 18 мин."
        }
        let lastFeed = vm.logEntries.first(where: { $0.kind == .bottle })?.time
        let mins = lastFeed.map { max(0, Int(-$0.timeIntervalSinceNow / 60)) } ?? 0
        if mins >= 150 {
            return "Прошло \(vm.lastFeedAgoString) с прошлого кормления — обычно \(displayName) ест в это время. Если плачет — попробуйте сначала грудь."
        }
        return "В этот скачок \(displayName) особенно интересны контрасты — покажите чёрно-белую книжку."
    }

    // MARK: - Leap Card

    private var leapCard: some View {
        HStack(spacing: 12) {
            CuteBlobView(kind: .moon, size: 48, tone: .bbLilac)
            VStack(alignment: .leading, spacing: 2) {
                Text("СКАЧОК №4 · ДЕНЬ 3 ИЗ ~5")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbLilacDeep)
                    .kerning(0.4)
                Text("«Мир событий» — это нормально")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInk)
                Text("Плачет, плохо спит, просит руки. Он не болен — он растёт.")
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
            QuickItem(kind: .bottle, tone: .bbCoral, label: "Еда")    { showFeeding = true },
            QuickItem(kind: .sleep,  tone: .bbLilac, label: "Сон")    { vm.logSleep() },
            QuickItem(kind: .drop,   tone: .bbSky,   label: "Памп")   { vm.logDiaper() },
            QuickItem(kind: .heart,  tone: .bbRose,  label: "Симптом") { showSymptom = true },
        ]
    }

    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: "Быстро записать")
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
                Text("Сегодня уже было")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Spacer()
                Text("\(vm.logEntries.count) записей")
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
                        CuteBlobView(kind: entry.kind, size: 32, tone: entry.tone)
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
    TodayView()
}
